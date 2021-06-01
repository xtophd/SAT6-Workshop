#!/bin/bash

##
## NOTE: you must point to the correct inventory
##

myInventory="./config/master-config.ini"

## This script is intended to be run:
##     on the libvirt hypervisor node
##     in the project directory
##     EX: CWD == ~root/OCP4-Workshop

if [ ! -e "${myInventory}" ] ; then
    echo "ERROR: Are you in the right directory? Can not find ${myInventory}" ; exit
    exit
fi

if [ ! -e "./playbooks" ] ; then
    echo "ERROR: Are you in the right directory? Can not find ./playbooks" ; exit
    exit
fi

##
##
##

case "$1" in
    "all")
        time  ansible-playbook --ask-vault-pass -i ${myInventory} -f 10  ./playbooks/sat6.yml
        ;;
         
    "registration"  | \
    "repos"         | \
    "prep"          | \
    "install"       | \
    "postinstall")

        time  ansible-playbook --ask-vault-pass -i ${myInventory} -f 10 --tags $1 ./playbooks/sat6.yml
        ;;

    *)
        echo "USAGE: prepare-sat6-workshop.sh [ all | registration | repos | prep | install | postinstall ]"
        ;;

esac         

