pve-nag-buster 

Persistent license nag removal for Proxmox VE 5.x+

This is a dpkg post install hook script that persistently removes license nags from
Proxmox VE 5.x+

The dpkg hook script removes the "unlicensed node" popup nag from the web gui and switches
repositories from pve-enterprise to pve-no-subscription. The script is called every time a
package updates the web gui or the pve-enterprise source list and will only run if
packages containing those files are changed. There are no external dependencies beyond the
base packages installed with PVE by default (awk, sed, grep, wget).

For your convenience the install script also contains a base64 encoded copy of
pve-nag-buster.sh for use offline without access to github or a full clone of the project.
To inspect the base64 encoded script run `bash install.sh --emit`; this dumps the encoded
copy to stdout and quits.

To install: 

```
wget https://raw.githubusercontent.com/foundObjects/pve-nag-buster/master/install.sh
# Read the script
sudo bash install.sh
```

Please get in touch if you find a way to improve anything, otherwise enjoy!
