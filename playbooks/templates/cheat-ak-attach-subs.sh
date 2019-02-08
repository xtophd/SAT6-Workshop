#!/bin/bash

echo "Attach Subscriptions to Activation Keys

UUID=`hammer --output base subscription list --organization "{{ myOrganization }}"  | grep UUID | awk '{ print $2 }'`

echo "Found Sub UUID: ${UUID}"

hammer activation-key add-subscription \
  --name "desktop-dev" \
  --subscription-id ${UUID} \
  --organization "{{ myOrganization }}"

hammer activation-key add-subscription \
  --name "desktop-prod" \
  --subscription-id ${UUID} \
  --organization "{{ myOrganization }}"
