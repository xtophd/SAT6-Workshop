#!/bin/bash

echo "## Cleaning YUM cache and other meta data"
yum clean all

echo "## Disabling local yum repos"
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/rhel7.repo
