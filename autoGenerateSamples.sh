#!/usr/bin/expect -f
set timeout -1
spawn bash generateSamples.sh -f decay_darkphoton_generic.cmnd --mD 2.0 --T 2.0 -e /eos/user/g/gdecastr/madanalysis5/samples/SUEPs/Generic_2_2 -n 290 -c 1000
expect {
    "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
    eof
}
