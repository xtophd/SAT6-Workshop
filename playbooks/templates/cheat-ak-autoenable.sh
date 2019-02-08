#!/bin/bash

echo "Activation Key Content Auto Enablement"

hammer activation-key content-override \
--name "desktop-dev" \
--content-label rhel-7-server-satellite-tools-6.4-rpms \
--value 1 \
--organization "{{ myOrganization }}"

hammer activation-key content-override \
--name "desktop-prod" \
--content-label rhel-7-server-satellite-tools-6.4-rpms \
--value 1 \
--organization "{{ myOrganization }}"
