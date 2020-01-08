#!/bin/bash

_VERS="v03"

sed "s/__VERSION__/$_VERS/g" src/script > "pve-nag-buster.sh"

# I have no idea what I'm doing 🐶
awk 'FNR==NR{s=(!s)?$0:s RS $0;next} /__BASE64__/{sub(/__BASE64__/, s)} 1' \
  <(xz -z -9 -c pve-nag-buster.sh | base64) src/install > install.sh
sed -i "s/__VERSION__/$_VERS/g" install.sh
