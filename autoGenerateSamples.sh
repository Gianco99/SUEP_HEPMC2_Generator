#!/usr/bin/expect -f
set timeout -1
spawn bash generateSamples.sh -f decay_darkphoton_hadronic.cmnd --mD 3.0 --T 12.0 -o /path/to/AFS/output -e /path/to/EOS/output -n 250 -c 1000
expect {
    "Enter PEM pass phrase" {sleep 1; send "MYPASSWORD\r"; exp_continue }
    eof
}
