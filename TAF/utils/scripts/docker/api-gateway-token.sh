#!/bin/sh

option=${1}
PROXY_IMAGE=$(docker inspect --format='{{.Config.Image}}' edgex-proxy-setup)
PROXY_NETWORK_ID=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' edgex-proxy-setup)

# Command vars
USER="gateway"
GROUP="gateway-group"

# JWT File
JWT_FILE=/tmp/edgex/secrets/security-proxy-setup/kong-admin-jwt
JWT_VOLUME=/tmp/edgex/secrets/security-proxy-setup

if [ ! -f "${WORK_DIR}/${USER}.pub" ];
then
  openssl ecparam -name prime256v1 -genkey -noout -out ${WORK_DIR}/${USER}.key 2> /dev/null
  openssl ec -in ${WORK_DIR}/${USER}.key -pubout -out ${WORK_DIR}/${USER}.pub 2> /dev/null
fi

case ${option} in
  -useradd)
    # Create a user in Kong
    ID=`cat /proc/sys/kernel/random/uuid 2> /dev/null` || ID=`uuidgen`
    docker run --rm -e KONGURL_SERVER=kong -e "ID=${ID}" -e "JWT_FILE=${JWT_FILE}" -e "USER=${USER}" \
           -e "GROUP=${GROUP}" --network=${PROXY_NETWORK_ID} --entrypoint "" -v ${WORK_DIR}:/keys -v ${JWT_VOLUME}:${JWT_VOLUME} ${PROXY_IMAGE} \
           /bin/sh -c 'JWT=`cat ${JWT_FILE}`; /edgex/secrets-config proxy adduser --jwt ${JWT} --token-type jwt --id ${ID} \
           --algorithm ES256 --public_key /keys/${USER}.pub --user ${USER} --group ${GROUP} > /dev/null'

    # Create JWT and associate with Kong user in previous step
    docker run --rm -e KONGURL_SERVER=kong -e "ID=${ID}" -e "USER=${USER}" --network=${PROXY_NETWORK_ID} --entrypoint "" \
           -v ${WORK_DIR}:/keys ${PROXY_IMAGE} /bin/sh -c '/edgex/secrets-config proxy \
           jwt --algorithm ES256 --id ${ID} --private_key /keys/${USER}.key'
  ;;
  -userdel)
    # Remove a user from Kong
    docker run --rm -e KONGURL_SERVER=kong -e "JWT_FILE=${JWT_FILE}" -e "USER=${USER}" --network=${PROXY_NETWORK_ID} --entrypoint "" \
           -v ${WORK_DIR}:/keys -v ${JWT_VOLUME}:${JWT_VOLUME} ${PROXY_IMAGE} /bin/sh -c 'JWT=`cat ${JWT_FILE}`; /edgex/secrets-config proxy \
           deluser --user ${USER} --jwt ${JWT} > /dev/null'
  ;;
  *)
    exit 0
  ;;
esac

# Clean up
rm ${WORK_DIR}/${USER}*
