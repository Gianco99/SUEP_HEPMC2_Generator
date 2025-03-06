#!/usr/bin/expect -f
set timeout -1
spawn bash generateSamples.sh -e /eos/output/path
expect {
    "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
    eof
}
