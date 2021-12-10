#!/bin/bash

option=${1}
# Command vars
USER="gateway"
GROUP="gateway-group"

. "$SCRIPT_DIR/snap-utils.sh"

snap_maybe_switch_asc_profile
 
# JWT File
JWT_FILE=/var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt
JWT_VOLUME=/var/snap/edgexfoundry/current/secrets/security-proxy-setup
JWT=`cat ${JWT_FILE}`

mkdir -p ${WORK_DIR}/keys

if [ ! -f "${WORK_DIR}/keys/${USER}.pub" ];
then
  openssl ecparam -name prime256v1 -genkey -noout -out ${WORK_DIR}/keys/${USER}.key > /dev/null 2>&1
  openssl ec -in ${WORK_DIR}/keys/${USER}.key -pubout -out ${WORK_DIR}/keys/${USER}.pub > /dev/null 2>&1
fi

case ${option} in
  -useradd)
    # Create a user in Kong
    ID=`cat /proc/sys/kernel/random/uuid 2> /dev/null` || ID=`uuidgen`
    edgexfoundry.secrets-config proxy adduser --jwt ${JWT} --token-type jwt --id ${ID} \
           --algorithm ES256 --public_key ${WORK_DIR}/keys/${USER}.pub --user ${USER} --group ${GROUP}  > /dev/null 2>&1

    # Create JWT and associate with Kong user in previous step. This script returns the token in stdout
    edgexfoundry.secrets-config proxy jwt --algorithm ES256 --id ${ID} --private_key ${WORK_DIR}/keys/${USER}.key 2> /dev/null
  ;;
  -userdel)
    # Remove a user from Kong
    edgexfoundry.secrets-config proxy deluser --user ${USER} --jwt ${JWT} > /dev/null 2>&1
  ;;
  *)
    exit 0
  ;;
esac


>&2 echo "INFO:snap-TAF: api-gateway-token done"

