#!/bin/sh
case "$SHELL" in "*/bash") set -euo pipefail ;; *) set -eu ;; esac

# pve-nag-buster (v03) https://github.com/foundObjects/pve-nag-buster
# Copyright (C) 2019 /u/seaQueue (reddit.com/u/seaQueue)
#
# Removes Proxmox VE 5.x+ license nags automatically after updates
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# ensure a predictable environment
PATH=/usr/sbin:/usr/bin:/sbin:/bin
unalias -a

# installer main body:
_main() {
  # ensure $1 exists so 'set -u' doesn't error out
  [ "$#" -eq "0" ] && { set -- ""; } > /dev/null 2>&1

  case "$1" in
    "--emit")
      # call the emit_script() function to stdout and exit, use this to verify
      # that the base64 encoded script below isn't doing anything malicious
      # does not require root
      emit_script
      ;;
    "--uninstall")
      # uninstall, requires root
      assert_root
      _uninstall
      ;;
    "--install" | "--offline" | "")
      # install dpkg hooks, requires root
      assert_root
      _install "$@"
      ;;
    *)
      # unknown flags, print usage and exit
      _usage
      ;;
  esac
  exit 0
}

_uninstall() {
  set -x
  [ -f "/etc/apt/apt.conf.d/86pve-nags" ] &&
    rm -f "/etc/apt/apt.conf.d/86pve-nags"
  [ -f "/usr/share/pve-nag-buster.sh" ] &&
    rm -f "/usr/share/pve-nag-buster.sh"

  echo "Script and dpkg hooks removed, please manually remove /etc/apt/sources.list.d/pve-no-subscription.list if desired"
}

_install() {
  # create hooks and no-subscription repo list, install hook script, run once

  RELEASE=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release)

  # create the pve-no-subscription list
  echo "Creating PVE no-subscription repo list ..."
  cat <<- EOF > "/etc/apt/sources.list.d/pve-no-subscription.list"
	# .list file automatically generated by pve-nag-buster at $(date)
	#
	# If pve-nag-buster is installed again this file will be overwritten
	#

	deb http://download.proxmox.com/debian/pve $RELEASE pve-no-subscription
	EOF

  # create dpkg pre/post install hooks for persistence
  echo "Creating dpkg hooks in /etc/apt/apt.conf.d ..."
  cat <<- 'EOF' > "/etc/apt/apt.conf.d/86pve-nags"
	DPkg::Pre-Install-Pkgs {
	    "while read -r pkg; do case $pkg in *proxmox-widget-toolkit* | *pve-manager*) touch /tmp/.pve-nag-buster && exit 0; esac done < /dev/stdin";
	};

	DPkg::Post-Invoke {
	    "[ -f /tmp/.pve-nag-buster ] && { /usr/share/pve-nag-buster.sh; rm -f /tmp/.pve-nag-buster; }; exit 0";
	};
	EOF

  echo "Installing script to /usr/share/pve-nag-buster.sh"
  temp=''
  if [ "$1" = "--offline" ]; then
    # offline mode, emit stored script
    temp="$(mktemp)" && trap "rm -f $temp" EXIT
    emit_script > "$temp"
  elif [ -f "pve-nag-buster.sh" ]; then
    # local copy available
    temp="pve-nag-buster.sh"
  else
    # fetch from github
    temp="$(mktemp)" && trap "rm -f $temp" EXIT
    wget https://raw.githubusercontent.com/foundObjects/pve-nag-buster/master/pve-nag-buster.sh \
      -O "$temp"
  fi
  install -o root -m 0550 "$temp" "/usr/share/pve-nag-buster.sh"
  /usr/share/pve-nag-buster.sh
  return 0
}

# emit a stored copy of pve-nag-buster.sh offline -- this is intended to be used during
# offline provisioning where we don't have access to github or a full cloned copy of the
# project

# run 'install.sh --emit' to dump stored script to stdout

# Important: if you're not me you should probably decode this and read it to make sure I'm not doing
#            something malicious like mining dogecoin or stealing your valuable cat pictures

# pve-nag-buster.sh (v03) encoded below:

emit_script() {
  base64 -d << 'YEET' | unxz
/Td6WFoAAATm1rRGAgAhARwAAAAQz1jM4AX2A4pdABGIQkY99BY0cwoNj8U0dcgowbs41qLC+aej
mGQYj9kDeUYQYXlQbEahoJLO08e8hIe8MoGJqvcVxM5VQehFNPqq4OH1KhbHgYGz5QSdcYFBPv2D
jY49iua72aQVDTzDsGFB7NKSSnbJvwPX6WvyHPM+YSTXqQiWDjian8iINwzsA43yWdFI1mOKn0/4
hRFy2JOUfs8lSPi0/lWwPBTpu1rk8jjFllid/53iIKUdAJXEB46QLnHWh93dffa4T3Nw1iUFI8t7
qYqwC05lZZRcxH6rR5siMu0IvrWPOFdk3RC+Hxu6cWGNwQU3Qg2Fp1eL6OxV25ZlKkxHsbV/1RZQ
v6oO3yN+u+fE8Hosh5Menm0W/xjo3+gN//tRxBjE7djbi3yE58fcnL00PCgdpZ7jbVUMBOSxafAK
QvTqN2M66xEeugkFWTXwj/j1ByAa3vCbmgfvUDFsznJs88AlZIlUfI8FJY7DW715ULQ1A7Ot/u29
cj9ZY9m6TgbXY1CvOb3HPcVxTUWT86agk3YSDiuIEuTXUTY/CF3mtDhk51uWI16D8K/P3JkBnZJl
Iv1jMe8GbydGG6vzOkzowGdOdYaktPn595lEAhwqSPgRwvBth+1x/gWiHhycK0ggFWUpclYOM3WH
+JAerc7G41krKJQyJYwsCKOnLhkMb5d0zLCs1VYbY1/u9XpG59SL1oVeIHcSKhXQhVu6/04iBAHH
otL1ZRuK5uRagpRKv0xLpi73waXAxeGczB7MtyFnUhU2+HcDQoZ2t+P1JkSaZPL9pkJtCWXb7wcn
ldyo8h7NOqf3Zg8BZydHQQ7zxUDXEHaDEhihpx+fYLuDnSdYT401yoXXQIGeWrbUEE4zazNRYngl
vVKMheX3lnXwD0u+lp6Yz5fKUJMvZKq7QpziFyNm5KbrRrj42DmH3Y+rftk2duVV2g1YDHiY/I3f
BBnK4IepebpLICNN+vKaYnAmxiO1Xfpzm0XTU7OPR+N6269sBlUtwK1mdM5b4bxNveo6nMz/MDlZ
Iuf4iF+nbiIhXIN8xfaBSOFUwxcANeaOxYLMfjMS05v1NtMOqEdIYzVXni0DHqtxs9dQaaM/jC4S
mwrfKTTLKCewSTGVsFSOGNPwOAM5/Fxu3snKRlYeLwKC7uq9uTFR/L64HzG0TPfjmkH24hNsuhe7
JtcdlRcbL5rHN9C5PNOpCqcEeRDmVsS0sgAAAMwFRS7YkAXGAAGmB/cLAADBO9SpscRn+wIAAAAA
BFla
YEET
}

assert_root() { [ "$(id -u)" -eq '0' ] || { echo "This action requires root." && exit 1; }; }
_usage() { echo "Usage: $(basename "$0") (--emit|--offline|--uninstall)"; }

_main "$@"
