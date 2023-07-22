#!/bin/bash


myInventory="./setup.yml"

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
        time  ansible-playbook --ask-vault-pass -i ${myInventory} -f 10  ./playbooks/sat6-automation.yml
        ;;

    "manifest"        | \
    "repositories"    | \
    "lifecycles"      | \
    "contentviews"    | \
    "activationkeys"  | \
    "client-reg"    )

        time  ansible-playbook --ask-vault-pass -i ${myInventory} -f 10 --tags $1 ./playbooks/sat6-automation.yml
        ;;

    *)
        echo "USAGE: sat6-workshop.sh [ all | manifest | repositories | lifecycles | contentviews | activationkeys | client-reg ]"
        ;;

esac

