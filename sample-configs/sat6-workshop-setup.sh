#!/bin/bash

RELOADER="$0"
echo "${RELOADER}"
echo "--------------------"

source ./xtoph-setup/xtoph-setup.shlib
source ./xtoph-setup/virthost-menu.shlib
source ./xtoph-setup/network-menu.shlib
source ./xtoph-setup/ansible-menu.shlib
source ./xtoph-setup/node-menu.shlib
source ./xtoph-setup/ldap-menu.shlib

# --

##
##    Variables unique to this Project
##

export PROJECT_NAME=""

export SATELLITE_VERSION=""
export SATELLITE_DISK="auto"
export SATELLITE_MANIFEST=""
export SATELLITE_UID="admin"
export RHSM_UID=""
export BMC_UID_DEFAULT=""

export WORKSHOP_ADMIN_UID="cloud-admin"
export WORKSHOP_STUDENT_UID="cloud-user"

export SATELLITE_PW
export WORKSHOP_ADMIN_PW
export WORKSHOP_STUDENT_PW
export RHSM_PW
export BMC_PW_DEFAULT


##
##    ESTABLISH SOME DEFAULTS
##

NAME_NODE1="bastion"
NAME_NODE2="satellite"
NAME_NODE3="node3"
NAME_NODE4="node4"
NAME_NODE5="node5"
NAME_NODE6="node6"

NICMOD_NODE1="static"
NICMOD_NODE2="dhcp"
NICMOD_NODE3="dhcp"
NICMOD_NODE4="dhcp"
NICMOD_NODE5="dhcp"
NICMOD_NODE6="dhcp"

HGROUP_NODE1="myBastion"
HGROUP_NODE2="mySatellite"
HGROUP_NODE3="myNodes"
HGROUP_NODE4="myNodes"
HGROUP_NODE5="myNodes"
HGROUP_NODE6="myNodes"

##
##    Load current answer file
##

[[ -e ./config/sat6-workshop-setup.ans ]] && . ./config/sat6-workshop-setup.ans

# ---

cluster_dump () {

##
##    NOTE: don't save passwords
##          user will always need
##          to enter ALL of them
##

cat <<EOVARS

## PROJECT SETTINGS

    PROJECT_NAME="${PROJECT_NAME}"
    SATELLITE_VERSION="${SATELLITE_VERSION}"
    SATELLITE_DISK="${SATELLITE_DISK}"
    SATELLITE_MANIFEST="${SATELLITE_MANIFEST}"
    SATELLITE_UID="${SATELLITE_UID}"
    RHSM_UID="${RHSM_UID}"

    WORKSHOP_ADMIN_UID="${WORKSHOP_ADMIN_UID}"
    WORKSHOP_STUDENT_UID="${WORKSHOP_STUDENT_UID}"

    ##SATELLITE_PW=""
    ##RHSM_PW=""

    ##WORKSHOP_ADMIN_PW=""
    ##WORKSHOP_STUDENT_PW=""

EOVARS

}

# ---

save_settings () {

    ##
    ##    NOTE: don't save passwords
    ##          user will always need
    ##          to enter ALL of them
    ##

    ##
    ##    NOTE:  Network broadcast and netmask
    ##           are calculated from the prefix
    ##           and also not saved
    ##

    if [[ ! -z ${NETWORK_PREFIX} && ! -z ${NETWORK_ID} ]]; then
        NETWORK_BROADCAST=`ipcalc ${NETWORK_ID}/${NETWORK_PREFIX} -b | cut -d= -f2`
        NETWORK_NETMASK=`ipcalc ${NETWORK_ID}/${NETWORK_PREFIX} -m | cut -d= -f2`
    fi

    cluster_dump  >  ./config/sat6-workshop-setup.ans 
    ansible_dump  >> ./config/sat6-workshop-setup.ans 
    network_dump  >> ./config/sat6-workshop-setup.ans 
    virthost_dump >> ./config/sat6-workshop-setup.ans 
    ldap_dump     >> ./config/sat6-workshop-setup.ans 
    node_dump     >> ./config/sat6-workshop-setup.ans 

}


# ---


cluster_settings () {

    ##
    ##    Bash Lesson:  the bash shell parameter expansion ':+' passes
    ##                  expansion if paramenter is set and not null
    ##

    echo ""
    echo "Project Name ... ${PROJECT_NAME}"
    echo ""

    echo "[ PROJECT ]"
    echo "    Satellite Version       ... ${SATELLITE_VERSION}"
    echo "    Satellite Disk          ... ${SATELLITE_DISK}"
    echo "    Satellite Manifest      ... ${SATELLITE_MANIFEST}"
    echo "    Workshop Admin UID/PW   ... ${WORKSHOP_ADMIN_UID} / ${WORKSHOP_ADMIN_PW:+"**********"}" 
    echo "    Workshop Student UID/PW ... ${WORKSHOP_STUDENT_UID} / ${WORKSHOP_STUDENT_PW:+"**********"}" 
    echo "    RHSM UID/PW             ... ${RHSM_UID} / ${RHSM_PW:+"**********"}" 
    echo "    Default BMC UID/PW      ... ${BMC_UID_DEFAULT} / ${BMC_PW_DEFAULT:+"**********"}" 

 }

# ---

current_settings () {
    cluster_settings
    ansible_settings
    network_settings
    virthost_settings
    ldap_settings
    node_settings
 }

# ---

cluster_bulk_edit () {

    TMPFILE="$(mktemp /var/tmp/ocp-workshop-setup.XXXXX)"

    cluster_dump > $TMPFILE

    vi $TMPFILE

    read -p "Accept BULK EDIT update (Y/N)? " input

    if [[ "${input^^}" == "Y" ]]; then
      source $TMPFILE
      echo "Changes sourced..."
    fi

    rm $TMPFILE

}


# ---

prepare_deployment () {

    echo ""

    echo "## Install Ansible from ${ANSIBLE_SOURCE}"

    case ${ANSIBLE_SOURCE} in 

      "RHSM") 
        ./sample-scripts/rhel9-install-ansible-rhsm.sh 
        ;;

      "EPEL") 
        ./sample-scripts/rhel9-install-ansible-epel.sh 
        ;;
    
      "INSTALLED") 
        echo " - success (ansible already installed)"
        ;;

      "*" )
        echo "WARNING: you must set a valid ansible source"
        return 1
        ;;
    esac



    echo -n "## Parsing sample-configs"



    echo -n "## Templating configuration files"
    ansible-playbook -e @playbooks/vars-sat6-attribs.yml sample-configs/sat6-workshop-setup.yml

    echo -n "## Encrypt the credentials.yml"

    if [[ -z "${ANSIBLE_VAULT_PW}" ]]; then
      echo " - FAILED" 
      echo "WARNING: you must set the ANSIBLE_VAULT_PW"
      return 1
    else
      echo "${ANSIBLE_VAULT_PW}" > ./config/vault-pw.tmp
      ansible-vault encrypt --vault-password-file ./config/vault-pw.tmp config/credentials.yml 1>/dev/null 2>&1

      if [[ $? ]] ; then
        rm -f ./config/vault-pw.tmp
        echo " - success" 
      else
        rm -f ./config/vault-pw.tmp
        echo " - FAILED" 
        return 1
      fi
    fi

}

# ---

cluster_menu () {

    SAVED_PROMPT="$PS3"

    PS3="PROJECT MENU: "

    echo ""
    cluster_settings
    echo ""

    select action in "RETURN to previous menu" \
                     "BULK EDIT params" \
                     "Set Project Name" \
                     "Set Satellite Version" \
                     "Set Satellite Disk" \
                     "Set Satellite Manifest" \
                     "Set Workshop Admin UID/PW" \
                     "Set Workshop Student UID/PW" \
                     "Set RHSM UID/PW" \
                     "Set Default BMC UID/PW"
    do
      case ${action}  in

        "RETURN to previous menu")
          PS3=${SAVED_PROMPT}
          break
          ;;

        "BULK EDIT params")
          cluster_bulk_edit
          ;;

        "Set Project Name")
          read -p "Enter Project Name [${PROJECT_NAME}]: " input
          PROJECT_NAME=${input:-$PROJECT_NAME}
          ;;

        "Set Satellite Version")
           select SATELLITE_VERSION in "6.18" "6.17" "6.16" "6.15" "6.14" "6.13" "6.12" "6.11" "6.10" "6.9" "6.8" "6.7" "6.6"
           do
              case ${SATELLITE_VERSION} in
                "6.18" | \
                "6.17" | \
                "6.16" | \
                "6.15" | \
                "6.14" | \
                "6.13" | \
                "6.12" | \
                "6.11" | \
                "6.10" | \
                "6.9"  | \
                "6.8"  | \
                "6.7"  | \
                "6.6"  )
                  SATELLITE_CLEANED_VER=`echo "${SATELLITE_VERSION}" | sed -e "s|\.||g"` 
                  SATELLITE_MANIFEST="manifest-v${SATELLITE_CLEANED_VER}.zip" 
                  break ;;

                "*" )
                  ;;
              esac
              REPLY=
            done
          ;;

        "Set Satellite Disk")
          read -p "Enter Satellite Disk ('auto' for defaults) [${SATELLITE_DISK}]: " input
          SATELLITE_DISK=${input:-$SATELLITE_DISK}
          ;;

        "Set Satellite Manifest")
          read -p "Enter Satellite Manifest filename [${SATELLITE_MANIFEST}]: " input
          SATELLITE_MANIFEST=${input:-$SATELLITE_MANIFEST}
          ;;

        "Set Workshop Admin UID/PW") 
          set_uidpw "Workshop Admin" "WORKSHOP_ADMIN_UID" "WORKSHOP_ADMIN_PW"
          ;;

        "Set Workshop Student UID/PW") 
          set_uidpw "Workshop Student" "WORKSHOP_STUDENT_UID" "WORKSHOP_STUDENT_PW"
          ;;

        "Set RHSM UID/PW") 
          set_uidpw "RHSM UID/PW"  "RHSM_UID" "RHSM_PW"
          ;;

        "Set Default BMC UID/PW")
          set_uidpw "BMC Default"    "BMC_UID_DEFAULT"    "BMC_PW_DEFAULT"
          ;;

        "*")
          echo "That's NOT an option, try again..."
          ;;

      esac

      ##
      ##    Reprint the current settings
      ##

      current_settings

      ##
      ##    The following causes the select
      ##    statement to reprint the menu
      ##

      REPLY=

    done

}

# ---

main_menu () {

    PS3="MAIN MENU [select action]: "

    current_settings

    select action in "PREPARE Deployment" \
                     "Project Settings" \
                     "Ansible Settings" \
                     "Network Settings" \
                     "Virt Host Settings" \
                     "LDAP Settings" \
                     "Node Settings"  \
                     "SAVE Current Params" \
                     "RELOAD Saved Params"
    do
      case ${action}  in

        "PREPARE Deployment")
          save_settings
          prepare_deployment
          ;;
        "SAVE Current Params")
          save_settings
          ;;
        "Ansible Settings")
          ansible_menu
          ;;
        "Project Settings")
          cluster_menu
          ;;
        "Network Settings")
          network_menu
          ;;
        "Virt Host Settings")
          virthost_menu
          ;;
        "LDAP Settings")
          ldap_menu
          ;;
        "Node Settings")
          node_menu
          ;;
        "SAVE Current Params")
          save_settings
          ;;
        "RELOAD Saved Params")
          exec "${RELOADER}"
          break
          ;;
        "*")
          echo "That's NOT an option, try again..."
          ;;       
 
      esac

      ##
      ##    Reprint the current settings
      ##

      echo ""
      current_settings
      echo ""

      ##
      ##    The following causes the select
      ##    statement to reprint the menu
      ##

      REPLY=

    done

}


##
##    Testing for 'ansible-playbook' command
##

[[ -x `which ansible-playbook` ]] && ANSIBLE_SOURCE="INSTALLED"


##
##    Engage the main_menu
##

main_menu

