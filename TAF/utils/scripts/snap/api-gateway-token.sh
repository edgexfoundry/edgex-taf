#!/bin/bash
 

option=${1}
# Command vars
USER="gateway"
GROUP="gateway-group"

# JWT File
JWT_FILE=/var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt
JWT_VOLUME=/var/snap/edgexfoundry/current/secrets/security-proxy-setup

mkdir -p ${WORK_DIR}/keys

if [ ! -f "${WORK_DIR}/keys/${USER}.pub" ];
then
  openssl ecparam -name prime256v1 -genkey -noout -out ${WORK_DIR}/keys/${USER}.key 2> /dev/null
  openssl ec -in ${WORK_DIR}/keys/${USER}.key -pubout -out ${WORK_DIR}/keys/${USER}.pub 2> /dev/null
fi

case ${option} in
  -useradd)
    # Create a user in Kong
    ID=`cat /proc/sys/kernel/random/uuid 2> /dev/null` || ID=`uuidgen`
    JWT=`sudo cat ${JWT_FILE}`
    edgexfoundry.secrets-config proxy adduser --jwt ${JWT} --token-type jwt --id ${ID} \
           --algorithm ES256 --public_key ${WORK_DIR}/keys/${USER}.pub --user ${USER} --group ${GROUP}  > /dev/null

    # Create JWT and associate with Kong user in previous step
    edgexfoundry.secrets-config proxy jwt --algorithm ES256 --id ${ID} --private_key ${WORK_DIR}/keys/${USER}.key
  ;;
  -userdel)
    # Remove a user from Kong
    JWT=`sudo cat ${JWT_FILE}`
    edgexfoundry.secrets-config proxy deluser --user ${USER} --jwt ${JWT} > /dev/null
  ;;
  *)
    exit 0
  ;;
esac

# Clean up
rm ${WORK_DIR}/keys/${USER}*

 