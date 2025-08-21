This repository is a fork of suep_generator and is licensed under the Apache License, Version 2.0. Please see the LICENSE file for full details.

This repository provides utilities for generating SUEP samples in the HEPMC format. It is designed to allow individuals to generate SUEP samples without having to worry about extraneous software dependencies. This repository hosts a fixed version of a Pythia installation (8.312) and a fork of the [SUEP_Generator](https://github.com/Gianco99/SUEP_Generator). These are the only versions of these software packages where the steps outlined below are guaranteed to work.

The [SUEP_Generator](https://github.com/Gianco99/SUEP_Generator) software package this Docker image uses is designed to generate SUEP samples which mimic the CMSSW Pythia tune so that they closely resemble the samples used to derive the results in the [PAS](https://cms-results.web.cern.ch/cms-results/public-results/preliminary-results/EXO-24-030/).

To begin producing SUEP HepMC signal samples, simply clone the repository to your desired path and checkout the `WH` branch.

**Note for lxplus Users**: Please clone this repository within your own AFS user-space as EOS is not compatible with Docker images which will be required in subsequent steps.

```bash
git clone https://github.com/Gianco99/SUEP_HEPMC2_Generator.git
cd SUEP_HEPMC2_Generator
git checkout WH
```

This is where the fun begins. There is a file named `DockerFile` which performs a series of installations and compilations. Here is a brief list of the things it is running:
   * Pulls a base Alpine Docker image
   * Installs Hepmc2.06.11
   * Installs LHAPDF-6.4.0
   * Installs the NNPDF31_nnlo_as_0118 PDF set (to mimic the CMS reconstruction tune)
   * Build Pythia8 with LHAPDF compatibility
   * Compile the SUEP_generator repo against our Pythia install

You can build this Docker image, which we will call `suep-generator-WH`, by running the command below:

```bash
cd SUEP_HEPMC2_Generator
docker build -t suep-generator-wh .
```

As the name implies, we will use `generateSamples.sh` to generate our HEPMC SUEP samples. The arguments of this script are described in detail below:

   * -i: The name of the image (the default is suep-generator-ZH)
   * -f: The Pythia cards used to define the decay mode of the dark photons (A'). The different cards can be found in the path `SUEP_HEPMC2_Generator/suep_generator/decay_cards`.
   * -mD: The mass of the dark meson - $m_{\phi} \in [2m_{A'}, 8]$ GeV
   * -T: The Boltzmann temperature - $T_D \in [m_{\phi}/4, 4m_{\phi}]$ GeV
   * -o: The output directory
   * -e: The EOS output directory (only given if working in Lxplus)
   * -c: The number of events per run
   * -n: The number of runs of c events

Follow the tutorial using one of the two subsections below depending on if you are working in Lxplus.

### Non-lxplus Users
Directly run the `generateSamples.sh` command (without using the optional `-e` argument). In the example below, we produce 100 files with 2000 events corresponding to SUEP decays generated using the hadronic decay mode with $m_{\phi} = T_D = 2$ GeV. The files are output to the path denoted by the `-o` argument.

```bash
cd SUEP_HEPMC2_Generator
bash generateSamples.sh -i suep-generator-WH -f decay_darkphoton_hadronic.cmnd --mD 2.0 --T 2.0 -o /path/to/output -n 100 -c 2000
```