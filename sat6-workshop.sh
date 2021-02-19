#!/bin/bash

##
## NOTE: you must point to the correct inventory
##

myInventory="./config/master-config.yml"
myExtravars="./config/libvirt-config.yml"

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
        echo "ansible-playbook -i ${myInventory} -f 10  ./playbooks/sat6.yml"
        time  ansible-playbook -i ${myInventory} -f 10  ./playbooks/sat6.yml
        ;;
         
    "registration"  | \
    "repos"         | \
    "prep"          | \
    "install"       | \
    "postinstall")

        echo "ansible-playbook -i ${myInventory} -f 10 --tags $1 ./playbooks/sat6.yml"
        time  ansible-playbook -i ${myInventory} -f 10 --tags $1 ./playbooks/sat6.yml
        ;;

    *)
        echo "USAGE: sat6-workshop.sh [ all | registration | repos | prep | install | postinstall ]"
        ;;

esac         

