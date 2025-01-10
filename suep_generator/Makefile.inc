# PYTHIA configuration file.
# Generated on Di 8. Feb 13:46:16 CET 2022 with the user supplied options:
# --with-lhapdf6=/cvmfs/sft.cern.ch/lcg/releases/MCGenerators/lhapdf/6.3.0-3c8e0/x86_64-centos7-gcc8-opt/
# --with-fastjet3=/cvmfs/sft.cern.ch/lcg/releases/fastjet/3.3.4-0d9d5/x86_64-centos7-gcc8-opt/
# --with-hepmc2=/cvmfs/cms.cern.ch/slc7_amd64_gcc820/external/hepmc/2.06.07/

# Install directory prefixes.
PREFIX_BIN=/afs/cern.ch/work/b/bmaier/public/xMaurizio/pythia/pythia8244/bin
PREFIX_INCLUDE=/afs/cern.ch/work/b/bmaier/public/xMaurizio/pythia/pythia8244/include
PREFIX_LIB=/afs/cern.ch/work/b/bmaier/public/xMaurizio/pythia/pythia8244/lib
PREFIX_SHARE=/afs/cern.ch/work/b/bmaier/public/xMaurizio/pythia/pythia8244/share/Pythia8

# Compilation flags (see ./configure --help for further documentation).
ENABLE_SHARED=false
CXX=/cvmfs/sft.cern.ch/lcg/releases/gcc/8.3.0-cebb0/x86_64-centos7/bin/g++
CXX_COMMON=-O2  -pedantic -W -Wall -Wshadow -fPIC
CXX_SHARED=-shared
CXX_SONAME=-Wl,-soname,
LIB_SUFFIX=.so

# EVTGEN configuration.
EVTGEN_USE=false
EVTGEN_BIN=
EVTGEN_INCLUDE=
EVTGEN_LIB=

# FASTJET3 configuration.
FASTJET3_USE=true
FASTJET3_BIN=/cvmfs/sft.cern.ch/lcg/releases/fastjet/3.3.4-0d9d5/x86_64-centos7-gcc8-opt//bin
FASTJET3_INCLUDE=/cvmfs/sft.cern.ch/lcg/releases/fastjet/3.3.4-0d9d5/x86_64-centos7-gcc8-opt//include
FASTJET3_LIB=/cvmfs/sft.cern.ch/lcg/releases/fastjet/3.3.4-0d9d5/x86_64-centos7-gcc8-opt//lib

# HEPMC2 configuration.
HEPMC2_USE=true
HEPMC2_BIN=/cvmfs/cms.cern.ch/slc7_amd64_gcc820/external/hepmc/2.06.07//bin
HEPMC2_INCLUDE=/cvmfs/cms.cern.ch/slc7_amd64_gcc820/external/hepmc/2.06.07//include
HEPMC2_LIB=/cvmfs/cms.cern.ch/slc7_amd64_gcc820/external/hepmc/2.06.07//lib

# HEPMC3 configuration.
HEPMC3_USE=false
HEPMC3_BIN=
HEPMC3_INCLUDE=
HEPMC3_LIB=

# LHAPDF5 configuration.
LHAPDF5_USE=false
LHAPDF5_BIN=
LHAPDF5_INCLUDE=
LHAPDF5_LIB=

# LHAPDF6 configuration.
LHAPDF6_USE=true
LHAPDF6_BIN=/cvmfs/sft.cern.ch/lcg/releases/MCGenerators/lhapdf/6.3.0-3c8e0/x86_64-centos7-gcc8-opt//bin
LHAPDF6_INCLUDE=/cvmfs/sft.cern.ch/lcg/releases/MCGenerators/lhapdf/6.3.0-3c8e0/x86_64-centos7-gcc8-opt//include
LHAPDF6_LIB=/cvmfs/sft.cern.ch/lcg/releases/MCGenerators/lhapdf/6.3.0-3c8e0/x86_64-centos7-gcc8-opt//lib

# POWHEG configuration.
POWHEG_USE=false
POWHEG_BIN=
POWHEG_INCLUDE=
POWHEG_LIB=

# PROMC configuration.
PROMC_USE=false
PROMC_BIN=
PROMC_INCLUDE=
PROMC_LIB=

# ROOT configuration.
ROOT_USE=false
ROOT_BIN=
ROOT_LIBS=
CXX_ROOT=

# GZIP configuration.
GZIP_USE=false
GZIP_BIN=
GZIP_INCLUDE=
GZIP_LIB=

# BOOST configuration.
BOOST_USE=false
BOOST_BIN=
BOOST_INCLUDE=
BOOST_LIB=

# PYTHON configuration.
PYTHON_USE=false
PYTHON_BIN=
PYTHON_INCLUDE=
PYTHON_LIB=
