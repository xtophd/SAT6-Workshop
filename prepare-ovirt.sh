#!/bin/bash

##
## NOTE: you must point to the correct inventory and extravars yml
##
##   Take a sample configs from ./sample-configs and 
##   copy it to ./playbooks/config/{master,libvirt}-config.yml
##

myInventory="./config/master-config.yml"
myExtravars="./config/ovirt-config.yml"

## This script is intended to be run:
##     on the libvirt hypervisor node
##     in the project directory
##     EX: CWD == ~root/OCP4-Workshop

if [[ ! -e "${myInventory}" || ! -e "${myExtravars}" || ! -d "./playbooks" ]] ; then
    echo "ERROR: Are you in the right directory? Can not find ${myInventory} | ${myExtravars} | ./playbooks " ; exit
    exit
fi

##
##
##

case "$1" in
    "all")

        time  ansible-playbook --ask-vault-pass -i ${myInventory} -e @${myExtravars} -f 10  ./playbooks.deployer-kvm/ovirt.yml 
        ;;

    "deploy"     | \
    "undeploy"   | \
    "redeploy"   | \
    "basics"     | \
    "cockpit"    | \
    "network"    | \
    "postconfig" | \
    "postinstall"| \
    "prep"       | \
    "rhsm")

        time  ansible-playbook --ask-vault-pass -i ${myInventory} -e @${myExtravars} -f 10 --tags $1 ./playbooks.deployer-kvm/ovirt.yml 
        ;;

    *)
        echo "USAGE: prepare-ovirt.sh [ all | deploy | undeploy | redeploy | basics | cockpit | network | postconfig | postinstall | rhsm]"

        ;;

esac         
