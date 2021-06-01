#!/bin/bash

##
## NOTE: you must point to the correct inventory and extravars yml
##
##   Take a sample configs from ./sample-configs and 
##   copy it to ./playbooks/config/{master,libvirt}-config.yml
##

myInventory="./config/master-config.ini"

if [[ ! -e "${myInventory}" || ! -e "./xtoph-deploy.yml" ]] ; then
    echo "ERROR: Are you in the right directory? Can not find ${myInventory} | xtoph-deploy.yml" ; exit
    exit
fi

##
##
##

case "$1" in

    "deploy"     | \
    "undeploy"   | \
    "redeploy"   | \
    "workshop"   | \
    "setup+"     | \
    "setup")

        time  ansible-playbook --ask-vault-pass -i ${myInventory} -f 10 -e xtoph_deploy_cmd=${1} xtoph-deploy.yml
        ;;

    *)
        echo "USAGE: xtoph-deploy.sh [ setup | setup+ | deploy | undeploy | redeploy | workshop ]"
        echo ""
        echo "  setup     ... runs only 'setup' plays"
        echo "  setup+    ... runs both 'setup' and 'deploy' plays"
        echo "  deploy    ... runs only 'deploy' plays"
        echo "  undeploy  ... runs only 'undeploy' plays"
        echo "  redeploy  ... runs both 'undeploy' and 'deploy' plays"
        echo "  workshop  ... runs only the 'workshop' plays"
        ;;

esac         
