#!/bin/bash

# Default values
DEFAULT_DOCKER_IMAGE="suep-generator"
DEFAULT_INPUT_FILE="decay_darkphoton_hadronic.cmnd"
DEFAULT_mD=3.0
DEFAULT_T=3.0
DEFAULT_NUM_RUNS=50
DEFAULT_EVENTS=2000

# Function to display usage
usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -i IMAGE         Docker image (default: ${DEFAULT_DOCKER_IMAGE})"
  echo "  -f INPUT_FILE    Input file (default: ${DEFAULT_INPUT_FILE})"
  echo "  --mD VALUE       mD parameter (default: ${DEFAULT_mD})"
  echo "  --T VALUE        T parameter (default: ${DEFAULT_T})"
  echo "  -o OUTPUT_DIR    Output directory (default: \$(pwd)/output_\${mD}_\${T})"
  echo "  -e EOS_DIR       EOS directory (required)"
  echo "  -n NUM_RUNS      Number of runs (default: ${DEFAULT_NUM_RUNS})"
  echo "  -c EVENTS        Events per run (default: ${DEFAULT_EVENTS})"
  echo "  -h               Display this help message"
  echo ""
  echo "Example:"
  echo "  $0 -i my-image -f my_input.cmnd --mD 4.0 --T 2.5 -o /path/to/output -e /eos/path -n 100 -c 3000"
  exit 1
}

# Initialize variables with default values
docker_image="${DEFAULT_DOCKER_IMAGE}"
input_file="${DEFAULT_INPUT_FILE}"
mD="${DEFAULT_mD}"
T="${DEFAULT_T}"
num_runs="${DEFAULT_NUM_RUNS}"
events="${DEFAULT_EVENTS}"
output_dir=""
eos_dir=""

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--image)
      docker_image="$2"
      shift 2
      ;;
    -f|--input_file)
      input_file="$2"
      shift 2
      ;;
    --mD)
      mD="$2"
      shift 2
      ;;
    --T)
      T="$2"
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
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown parameter passed: $1"
      usage
      ;;
  esac
done

# Check if EOS_DIR is provided
if [[ -z "$eos_dir" ]]; then
  echo "Error: EOS_DIR (-e) is required."
  usage
fi

# Prepend the EOS prefix
eos_dir="root://eosuser.cern.ch/${eos_dir}"

# Set default output_dir if not provided
if [[ -z "$output_dir" ]]; then
  output_dir="$(pwd)/output_${mD}_${T}"
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
echo "Input File: $input_file"
echo "mD: $mD"
echo "T: $T"
echo "Output Directory: $output_dir"
echo "EOS Directory: $eos_dir"
echo "Number of Runs: $num_runs"
echo "Events per Run: $events"
echo ""

# Loop to generate the random seeds and run the Docker container
for ((i=1; i<=num_runs; i++)); do
  # Generate a random seed using /dev/urandom
  random_seed=$(od -An -N4 -tu4 < /dev/urandom | tr -d ' ')
  
  # Define the output file name with the random seed
  output_file="${random_seed}.hepmc"
  
  echo "Run #$i: Seed=$random_seed, Output File=$output_file"
  
  # Run the Docker command with the random seed
  docker run --rm -v "${output_dir}:/app/output" -it "${docker_image}" 125.0 "${mD}" "${T}" "${input_file}" "/app/output/${output_file}" "${random_seed}" "${events}"
  
  # Check if Docker run was successful
  if [[ $? -ne 0 ]]; then
    echo "Error: Docker run failed for seed $random_seed."
    continue
  fi
  
  # Copy the output to EOS with the random seed in the file name
  xrdcp -f "${output_dir}/${output_file}" "${eos_dir}/${output_file}"
  
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to copy ${output_file} to EOS."
    continue
  fi
  
  # Remove the local output file
  rm -f "${output_dir}/${output_file}"
  
  echo "Run #$i completed successfully."
  echo ""
done

echo "All runs completed."
