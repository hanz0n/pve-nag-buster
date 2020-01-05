#!/bin/bash

_VERS="v03"

_OUTFILE="pve-nag-buster.sh"

sed "s/__VERSION__/$_VERS/g" src/script > $_OUTFILE

_OUTFILE="install.sh"

sed "s/__VERSION__/$_VERS/g" src/install > $_OUTFILE
xz -z -9 -c pve-nag-buster.sh | base64 >> $_OUTFILE
printf "ENDMALWARE\n}\n" >> $_OUTFILE
