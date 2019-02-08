#!/bin/bash

echo "Creating Activation Keys for DEV and PROD"

hammer activation-key create \
  --name "desktop-dev" \
  --description "Desktops for development and early testing" \
  --lifecycle-environment "Desktop-DEV" \
  --content-view "Desktop-R7"  \
  --organization "{{ myOrganization }}"

hammer activation-key create \
  --name "desktop-prob" \
  --description "Desktops for development and early testing" \
  --lifecycle-environment "Desktop-PROD" \
  --content-view "Desktop-R7"  \
  --organization "{{ myOrganization }}"
