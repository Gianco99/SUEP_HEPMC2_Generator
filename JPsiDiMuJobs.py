#!/usr/bin/env python3
import os
import argparse
import shutil

# -------- Defaults --------
DEFAULT_MODE = "mu"  # mu or ele
DEFAULT_EVENTS_PER_JOB = 50_000
DEFAULT_RUNS = 1
DEFAULT_DOCKER_IMAGE = "suep-generator:latest"
DEFAULT_EXEC_PATHS = {
    "mu":  "/usr/local/pythia8312/SUEP/JPsi_DiMu",
    "ele": "/usr/local/pythia8312/SUEP/JPsi_DiEle",
}
DEFAULT_EOS_DEST = {
    "mu":  "/eos/user/g/gdecastr/HepMCSamples/JPsiDiMu",
    "ele": "/eos/user/g/gdecastr/HepMCSamples/JPsiDiEle",
}
DEFAULT_OUT_SCRIPT_DIR = os.path.expanduser("~/JPsi_CondorJobs")
DEFAULT_LOCAL_OUT_DIRS = {
    "mu":  "output_JPsiDiMu",
    "ele": "output_JPsiDiEle",
}

# Condor bits
JOB_FLAVOUR = "workday"  # tweak if needed


def write_wrapper(path: str, image: str, local_out_rel: str, eos_dest: str, mode: str,
                  events_per_job: int, exec_path: str):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as sh:
        sh.write("#!/bin/bash\n")
        sh.write("set -euo pipefail\n")
        sh.write("echo \"[$(date)] Starting JPsi job ($HOSTNAME)\"\n")
        sh.write("echo \"Scratch: ${_CONDOR_SCRATCH_DIR:-$PWD}\"\n")
        sh.write("SCRATCH_DIR=\"${_CONDOR_SCRATCH_DIR:-$PWD}\"\n")
        sh.write(f"OUTDIR=\"$SCRATCH_DIR/{local_out_rel}\"\n")
        sh.write("mkdir -p \"$OUTDIR\"\n")
        # Export the in-image binary path for generateJPsi.sh to consume
        sh.write(f"export EXECUTABLE_PATH='{exec_path}'\n")
        # Single run with chosen chunk size, writing to scratch OUTDIR
        sh.write(
            "bash generateJPsi.sh "
            f"-i '{image}' -o \"$OUTDIR\" -e '{eos_dest}' -n 1 -c {events_per_job} -m {mode}\n"
        )
        sh.write("status=$?; echo \"[$(date)] Exit status: $status\"; exit $status\n")
    os.chmod(path, 0o755)


def write_condor_submit(sub_path: str, scripts_dir: str):
    lines = []
    lines.append("universe              = vanilla")
    lines.append(f"+JobFlavour          = {JOB_FLAVOUR}")
    lines.append("transfer_executable   = True")
    # Ship the generate script to the worker
    lines.append("transfer_input_files  = generateJPsi.sh")
    lines.append("executable            = $(filename)")
    lines.append("arguments             = \n")
    lines.append("")
    lines.append(f"Log     = {os.path.join(scripts_dir, 'condor.log')}")
    lines.append(f"Output  = {os.path.join(scripts_dir, '$(Cluster).$(Process).out')}")
    lines.append(f"Error   = {os.path.join(scripts_dir, '$(Cluster).$(Process).err')}")
    lines.append("")
    lines.append(f"queue filename matching ({scripts_dir}/job_*.sh)")
    with open(sub_path, "w") as f:
        f.write("\n".join(lines))


def main():
    ap = argparse.ArgumentParser(description="Create Condor jobs to run generateJPsi.sh with N runs of M events each")
    ap.add_argument("--mode", choices=["mu", "ele"], default=DEFAULT_MODE, help="Channel to generate")
    ap.add_argument("--events", type=int, default=DEFAULT_EVENTS_PER_JOB, help="Attempted events per job")
    ap.add_argument("--runs", type=int, default=DEFAULT_RUNS, help="Number of jobs to create and queue")
    ap.add_argument("--image", default=DEFAULT_DOCKER_IMAGE, help="Docker image tag")
    ap.add_argument("--exe-path", default=None, help="In-image executable path (overrides default for mode)")
    ap.add_argument("--out-script-dir", default=DEFAULT_OUT_SCRIPT_DIR, help="Where to write wrapper scripts and submit file")
    ap.add_argument("--local-out-dir", default=None, help="Relative temp output dir; defaults per mode (stored in Condor scratch)")
    ap.add_argument("--eos-dest", default=None, help="EOS destination directory; defaults per mode")
    ap.add_argument("--gen-script", default="generateJPsi.sh", help="Path to generateJPsi.sh to ship with each job")
    args = ap.parse_args()

    mode = args.mode
    exec_path = args.exe_path or DEFAULT_EXEC_PATHS[mode]
    eos_dest = args.eos_dest or DEFAULT_EOS_DEST[mode]
    local_out_rel = args.local_out_dir or DEFAULT_LOCAL_OUT_DIRS[mode]

    # Prepare job directory
    jobdir = os.path.join(args.out_script_dir, mode)
    os.makedirs(jobdir, exist_ok=True)

    # Stage generateJPsi.sh into the jobdir
    gen_src = os.path.abspath(args.gen_script)
    if not os.path.isfile(gen_src):
        raise FileNotFoundError(f"generateJPsi.sh not found at: {gen_src}")
    gen_dst = os.path.join(jobdir, "generateJPsi.sh")
    shutil.copy2(gen_src, gen_dst)
    os.chmod(gen_dst, 0o755)

    # Write simple N wrappers
    for i in range(1, args.runs + 1):
        name = f"job_{mode}_{i:05d}.sh"
        path = os.path.join(jobdir, name)
        write_wrapper(
            path=path,
            image=args.image,
            local_out_rel=local_out_rel,
            eos_dest=eos_dest,
            mode=mode,
            events_per_job=args.events,
            exec_path=exec_path,
        )

    # Submit file
    sub_path = os.path.join(jobdir, f"condor_{mode}.sub")
    write_condor_submit(sub_path, scripts_dir=jobdir)

    print("\n=== Job set ready ===")
    print(f"Mode                 : {mode}")
    print(f"Events per job       : {args.events}")
    print(f"Runs (jobs)          : {args.runs}")
    print(f"Image                : {args.image}")
    print(f"Exec path in image   : {exec_path}")
    print(f"Temp out (scratch)   : {local_out_rel}")
    print(f"EOS destination      : {eos_dest}")
    print(f"Scripts directory    : {jobdir}")
    print(f"Submit with          : condor_submit {sub_path}")


if __name__ == "__main__":
    main()