#!/bin/bash

# Default values
DEFAULT_DOCKER_IMAGE="suep-generator"
DEFAULT_NUM_RUNS=500
DEFAULT_EVENTS=2000
DEFAULT_MODE="mu"

# Function to display usage
usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -i IMAGE         Docker image (default: ${DEFAULT_DOCKER_IMAGE})"
  echo "  -o OUTPUT_DIR    Output directory (default: $(pwd)/output)"
  echo "  -e EOS_DIR       EOS directory (default by mode: /eos/.../ZPrimeDiMu or /eos/.../ZPrimeDiEle)"
  echo "  -n NUM_RUNS      Number of runs (default: ${DEFAULT_NUM_RUNS})"
  echo "  -c EVENTS        Events per run (default: ${DEFAULT_EVENTS})"
  echo "  -m MODE          Channel: mu or ele (default: ${DEFAULT_MODE})"
  echo "  -x EXE_PATH     In-image executable path (default: /usr/local/pythia8312/SUEP/<exe>)"
  echo "  -s SIF_PATH     Path to a local .sif image (preferred on batch nodes; overrides docker://<image>)"
  echo "  -h               Display this help message"
  echo ""
  echo "Example:"
  echo "  $0 -i suep-generator -o /path/to/output -e /eos/user/g/gdecastr/HepMCSamples/ZPrimeDiMu -n 100 -c 3000 -m mu -x /usr/local/pythia8312/SUEP/ZPrime_DiMu -s /eos/user/g/gdecastr/HepMCSamples/singularityImages/suep-generator.sif"
  exit 1
}

# Initialize variables with default values
docker_image="${DEFAULT_DOCKER_IMAGE}"
num_runs="${DEFAULT_NUM_RUNS}"
events="${DEFAULT_EVENTS}"
output_dir=""
eos_dir=""
mode="${DEFAULT_MODE}"
executable_path=""
sif_image=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--image)
      docker_image="$2"
      shift 2
      ;;
    -o|--output_dir)
      output_dir="$2"
      shift 2
      ;;
    -e|--eos_dir)
      eos_dir="$2"
      shift 2
      ;;
    -n|--num_runs)
      num_runs="$2"
      shift 2
      ;;
    -c|--events)
      events="$2"
      shift 2
      ;;
    -m|--mode)
      mode="$2"
      shift 2
      ;;
    -x|--exe-path)
      executable_path="$2"
      shift 2
      ;;
    -s|--sif)
      sif_image="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown parameter passed: $1"
      usage
      ;;
  esac
done

# If EOS_DIR not provided, choose default by mode
if [[ -z "$eos_dir" ]]; then
  if [[ "$mode" =~ ^(mu|MU|Mu)$ ]]; then
    eos_dir="/eos/user/g/gdecastr/HepMCSamples/ZPrimeDiMu"
  else
    eos_dir="/eos/user/g/gdecastr/HepMCSamples/ZPrimeDiEle"
  fi
fi

# Expect EOS_DIR to be a plain filesystem path (e.g. /eos/user/...)
if [[ "$eos_dir" == root://* ]]; then
  echo "Error: EOS_DIR must be a filesystem path (e.g. /eos/user/...), not an XRootD URL: '$eos_dir'" >&2
  exit 2
fi
# Must be absolute
if [[ "${eos_dir:0:1}" != "/" ]]; then
  echo "Error: EOS_DIR must be an absolute path; got '$eos_dir'" >&2
  exit 2
fi
# Ensure destination dir exists (FUSE-mounted EOS)
if [[ ! -d "$eos_dir" ]]; then
  mkdir -p "$eos_dir" || { echo "Error: Failed to create EOS directory '$eos_dir'" >&2; exit 2; }
fi

# Choose executable based on mode
case "$mode" in
  mu|MU|Mu)
    executable="ZPrime_DiMu"
    ;;
  ele|ELE|Ele|electron|Electron|EE|ee)
    executable="ZPrime_DiEle"
    ;;
  *)
    echo "Error: invalid mode '$mode'. Use 'mu' or 'ele'."
    exit 1
    ;;
esac

# Choose in-image executable path (env override > CLI > default)
if [[ -n "${EXECUTABLE_PATH}" ]]; then
  executable_path="${EXECUTABLE_PATH}"
elif [[ -z "${executable_path}" ]]; then
  executable_path="/usr/local/pythia8312/SUEP/${executable}"
fi

# Prefer explicit SIF image via env or CLI; else use docker://<image>
if [[ -n "${SIF_IMAGE}" && -z "${sif_image}" ]]; then
  sif_image="${SIF_IMAGE}"
fi
if [[ -n "${sif_image}" ]]; then
  container_spec="${sif_image}"
else
  container_spec="docker://${docker_image}"
fi

# Set default output_dir if not provided
if [[ -z "$output_dir" ]]; then
  output_dir="$(pwd)/output"
fi

# Create output_dir if it doesn't exist
if [[ ! -d "$output_dir" ]]; then
  mkdir -p "$output_dir"
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create output directory '$output_dir'."
    exit 1
  fi
fi

# Define the Docker image and other paths (variables already set)

echo "Starting the script with the following parameters:"
echo "Docker Image: $docker_image"
echo "Output Directory: $output_dir"
echo "EOS Directory: $eos_dir"
echo "Number of Runs: $num_runs"
echo "Events per Run: $events"
echo "Flavor/Mode: $mode (executable: $executable)"
echo "Entrypoint Path: $executable_path"
echo "Container Spec: $container_spec"
echo ""

# Runtime env for Pythia inside the container
PYTHIA_PREFIX="/usr/local/pythia8312"
RUNTIME_LD_LIBRARY_PATH="${PYTHIA_PREFIX}/lib:/usr/local/lib"
RUNTIME_PYTHIA8DATA="${PYTHIA_PREFIX}/share/Pythia8/xmldoc"
RUNTIME_LHAPDF_DATA_PATH="/usr/local/share/LHAPDF"

run_in_container() {
  local outfile="$1"
  local seed="$2"
  local nevt="$3"

  # Prefer Apptainer/Singularity on batch nodes; fall back to Docker/Podman
  if command -v apptainer >/dev/null 2>&1; then
    echo "Using apptainer with: ${container_spec}"
    apptainer exec \
      --env LD_LIBRARY_PATH="${RUNTIME_LD_LIBRARY_PATH}" \
      --env PYTHIA8="${PYTHIA_PREFIX}" \
      --env PYTHIA8DATA="${RUNTIME_PYTHIA8DATA}" \
      --env LHAPDF_DATA_PATH="${RUNTIME_LHAPDF_DATA_PATH}" \
      -B "${output_dir}:/app/output" "${container_spec}" \
      "${executable_path}" "/app/output/${outfile}" "${seed}" "${nevt}"
    return $?
  elif command -v singularity >/dev/null 2>&1; then
    echo "Using singularity with: ${container_spec}"
    singularity exec \
      --env LD_LIBRARY_PATH="${RUNTIME_LD_LIBRARY_PATH}" \
      --env PYTHIA8="${PYTHIA_PREFIX}" \
      --env PYTHIA8DATA="${RUNTIME_PYTHIA8DATA}" \
      --env LHAPDF_DATA_PATH="${RUNTIME_LHAPDF_DATA_PATH}" \
      -B "${output_dir}:/app/output" "${container_spec}" \
      "${executable_path}" "/app/output/${outfile}" "${seed}" "${nevt}"
    return $?
  elif command -v docker >/dev/null 2>&1; then
    echo "Using docker with image: ${docker_image}"
    docker run --rm \
      -e LD_LIBRARY_PATH="${RUNTIME_LD_LIBRARY_PATH}" \
      -e PYTHIA8="${PYTHIA_PREFIX}" \
      -e PYTHIA8DATA="${RUNTIME_PYTHIA8DATA}" \
      -e LHAPDF_DATA_PATH="${RUNTIME_LHAPDF_DATA_PATH}" \
      -v "${output_dir}:/app/output" --entrypoint "${executable_path}" \
      "${docker_image}" "/app/output/${outfile}" "${seed}" "${nevt}"
    return $?
  elif command -v podman >/dev/null 2>&1; then
    echo "Using podman with image: ${docker_image}"
    podman run --rm \
      -e LD_LIBRARY_PATH="${RUNTIME_LD_LIBRARY_PATH}" \
      -e PYTHIA8="${PYTHIA_PREFIX}" \
      -e PYTHIA8DATA="${RUNTIME_PYTHIA8DATA}" \
      -e LHAPDF_DATA_PATH="${RUNTIME_LHAPDF_DATA_PATH}" \
      -v "${output_dir}:/app/output" --entrypoint "${executable_path}" \
      "${docker_image}" "/app/output/${outfile}" "${seed}" "${nevt}"
    return $?
  else
    echo "Error: No container runtime found (apptainer/singularity/docker/podman)." >&2
    return 127
  fi
}

# Loop to generate the random seeds and run the Docker container
for ((i=1; i<=num_runs; i++)); do
  # Generate a random seed
  random_seed=$(( ( RANDOM * RANDOM ) % 2147483647 + 1 ))
  
  # Define the output file name with the random seed
  output_file="${random_seed}.hepmc"
  
  echo "Run #$i: Seed=$random_seed, Output File=$output_file"
  
  # Run using whichever container runtime is available
  if ! run_in_container "${output_file}" "${random_seed}" "${events}"; then
    echo "Error: Container run failed for seed $random_seed."
    continue
  fi

  if [[ ! -s "${output_dir}/${output_file}" ]]; then
  echo "Warning: ${output_file} is empty. Skipping copy."
  rm -f "${output_dir}/${output_file}"
  continue
  fi
  
  # Copy the output into EOS FUSE path with the random seed in the file name
  dest="${eos_dir%/}/${output_file}"
  if ! cp -f "${output_dir}/${output_file}" "${dest}"; then
    echo "Error: Failed to copy ${output_file} to EOS path '${dest}'." >&2
    continue
  fi
  # Remove the local output file after successful copy
  rm -f "${output_dir}/${output_file}"
  
  echo "Run #$i completed successfully."
  echo ""
done

echo "All runs completed."
