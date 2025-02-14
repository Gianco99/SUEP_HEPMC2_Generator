#!/usr/bin/expect -f
set timeout -1
spawn bash generateSamples.sh -f decay_darkphoton_generic.cmnd --mD 5.0 --T 5.0 -e /eos/cms/store/group/phys_exotica/SUEPs/ZH_HepMC/Generic_5_5/ -n 300 -c 1000
expect {
    "Enter PEM pass phrase" {sleep 1; send "\r"; exp_continue }
    eof
}
