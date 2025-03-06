#!/usr/bin/expect -f
set timeout -1

# Initialize all parameters as empty strings.
set docker_image ""
set input_file ""
set mD ""
set T ""
set output_dir ""
set eos_dir ""
set num_runs ""
set events ""
set pem_password ""

# Function to display usage information
proc usage {} {
    puts "Usage: $argv0 [options]"
    puts ""
    puts "Options:"
    puts "  -i IMAGE         Docker image (optional)"
    puts "  -f INPUT_FILE    Input file (optional)"
    puts "  --mD VALUE       mD parameter (optional)"
    puts "  --T VALUE        T parameter (optional)"
    puts "  -o OUTPUT_DIR    Output directory (optional)"
    puts "  -e EOS_DIR       EOS directory (required)"
    puts "  -n NUM_RUNS      Number of runs (optional)"
    puts "  -c EVENTS        Events per run (optional)"
    puts "  -p PEM_PASSWORD  PEM password (required; default is blank if explicitly provided as empty)"
    puts "  -h               Display this help message"
    exit 1
}

# Parse command-line arguments
while {$argc > 0} {
    set arg [lindex $argv 0]
    switch -- $arg {
        -i -image {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set docker_image [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -f -input_file {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set input_file [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        --mD {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set mD [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        --T {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set T [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -o -output_dir {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set output_dir [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -e -eos_dir {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set eos_dir [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -n -num_runs {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set num_runs [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -c -events {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set events [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -p -pem {
            if {$argc < 2} {
                puts "Error: Missing value for $arg"
                usage
            }
            set pem_password [lindex $argv 1]
            set argv [lrange $argv 2 end]
        }
        -h -help {
            usage
        }
        default {
            puts "Unknown parameter: $arg"
            usage
        }
    }
}

# Check that the required EOS directory and PEM password are provided.
if {$eos_dir eq ""} {
    puts "Error: EOS directory (-e) is required."
    usage
}
if {$pem_password eq ""} {
    puts "Error: PEM password (-p) is required."
    usage
}

# Build the command to spawn generateSamples.sh.
# Only include optional parameters if they are not empty.
set cmd "bash generateSamples.sh"
if {$docker_image ne ""} { append cmd " -i $docker_image" }
if {$input_file ne ""} { append cmd " -f $input_file" }
if {$mD ne ""} { append cmd " --mD $mD" }
if {$T ne ""} { append cmd " --T $T" }
if {$output_dir ne ""} { append cmd " -o $output_dir" }
append cmd " -e $eos_dir"
if {$num_runs ne ""} { append cmd " -n $num_runs" }
if {$events ne ""} { append cmd " -c $events" }

puts "Running command: $cmd"

# Spawn the command and respond to the PEM pass phrase prompt with the provided password.
spawn $cmd
expect {
    "Enter PEM pass phrase" { sleep 1; send "$pem_password\r"; exp_continue }
    eof
}
