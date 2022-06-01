#!/bin/bash
shopt -s nullglob # avoid errors when no files match a pattern
PIP_REQ_TXT_DIR=${1%/}
PIP_REQ_DL_DIR=${2%/}
BRIGHT_PACKAGES_FILTER_STRINGS='bright|uaa|ucb|ems'
SKIP_PIP_INSTALL_PACKAGES='statsd'

if [[ $# -eq 0 ]]; then
    echo "Usage help: $0 <location_of_req_files> <download_location_for_packages>"
    exit 1
fi


if [[ -f /etc/pip.conf ]]; then
  echo "Removing /etc/pip.conf"
  sudo rm -f /etc/pip.conf
fi

# if ! [[ -f /etc/pip_bright_prod.conf ]]
#   echo "Running fast pip conf setup"
#   sudo echo "# BEGIN PACKER MANAGED BLOCK
# [global]
# extra-index-url=https://bright:TheFutureBank2030@pypi.brightmoney.co/snapshots/simple
# # END PACKER MANAGED BLOCK" > /etc/pip_bright_dev.conf
#   sudo echo "# BEGIN PACKER MANAGED BLOCK
# [global]
# extra-index-url=https://bright:TheFutureBank2030@pypi.brightmoney.co/simple
# # END PACKER MANAGED BLOCK" > /etc/pip_bright_prod.conf
#   sudo echo "# BEGIN PACKER MANAGED BLOCK
# [global]
# extra-index-url=https://bright:TheFutureBank2030@pypi.brightmoney.co/simple
#                 https://bright:TheFutureBank2030@pypi.brightmoney.co/snapshots/simple
# # END PACKER MANAGED BLOCK" > /etc/pip.conf.bak
# fi

if [[ $(ls -al1 $PIP_REQ_TXT_DIR | grep -c "prod\|global\|public") ]]; then
  echo "Bright fast pip installation requirements not found."
  if [[ -f $PIP_REQ_TXT_DIR/requirements.txt ]]; then
    echo "Spiliting $PIP_REQ_TXT_DIR/requirements.txt into requirements_global.txt and requirements_bright_prod.txt"
    cat $PIP_REQ_TXT_DIR/requirements.txt | grep -vE $BRIGHT_PACKAGES_FILTER_STRINGS | grep -vE $SKIP_PIP_INSTALL_PACKAGES >> $PIP_REQ_TXT_DIR/requirements_global.txt
    cat $PIP_REQ_TXT_DIR/requirements.txt | grep -E $BRIGHT_PACKAGES_FILTER_STRINGS | grep -vE $SKIP_PIP_INSTALL_PACKAGES >> $PIP_REQ_TXT_DIR/requirements_bright_prod.txt
  else
    echo "Generic requirements file missing, aborting installation"
    exit 2
  fi
fi

echo "Installation starting"

mkdir -p $PIP_REQ_TXT_DIR/logs/$(date -u +%FT%TZ) 

for reqfile in $PIP_REQ_TXT_DIR/*.txt;
do
  case $reqfile in
    *global* | *public* ) echo "Global: $reqfile" && sudo -u bright_tech -H python3 -m pip download --destination-directory $PIP_REQ_DL_DIR/global-packages -r $reqfile >> $PIP_REQ_TXT_DIR/logs/$(date -u +%FT%TZ)/global-packages.log;;
    *prod*              ) echo "Bright (Prod): $reqfile" && sudo -u bright_tech -H PIP_CONFIG_FILE=/etc/pip_bright_prod.conf python3 -m pip download --destination-directory $PIP_REQ_DL_DIR/bright-packages -r $reqfile >> $PIP_REQ_TXT_DIR/logs/$(date -u +%FT%TZ)/bright-prod-packages.log;;
    *dev*               ) echo "Bright (Dev): $reqfile" && sudo -u bright_tech -H PIP_CONFIG_FILE=/etc/pip_bright_dev.conf python3 -m pip download --destination-directory $PIP_REQ_DL_DIR/bright-packages -r $reqfile >> $PIP_REQ_TXT_DIR/logs/$(date -u +%FT%TZ)/bright-dev-packages.log;;
    *                   ) echo "Unsupported requirements file found: $reqfile";;
  esac
done
exit 0
