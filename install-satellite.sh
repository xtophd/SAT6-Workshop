#!/bin/bash

## This script is intended to be run:
##     on the control host (ie: workstation)
##     CWD =  ~root/SAT6-Workshop

myInventory="./configs/sat6-workshop"

if [ ! -e "${myInventory}" ] ; then
    echo "ERROR: Are you in the right directory? Can not find ${myInventory}" ; exit
    exit
fi

time ansible-playbook -i ${myInventory} -f 5 \
    ./playbooks/sat6-nodes-prep.yml \
    ./playbooks/sat6-server-prep.yml \
    ./playbooks/sat6-install.yml
