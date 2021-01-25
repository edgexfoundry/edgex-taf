#!/bin/sh

option=${1}
PROXY_IMAGE=$(docker inspect --format='{{.Config.Image}}' edgex-proxy-setup)
PROXY_NETWORK_ID=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' edgex-proxy-setup)

if [ ! -f "${WORK_DIR}/ec256.pub" ];
then
  openssl ecparam -name prime256v1 -genkey -noout -out ${WORK_DIR}/ec256.key 2> /dev/null
  cat ${WORK_DIR}/ec256.key | openssl ec -out ${WORK_DIR}/ec256.pub 2> /dev/null
fi

case ${option} in
  -useradd)
    #create a user
    ID=`cat /proc/sys/kernel/random/uuid 2> /dev/null` || ID=`uuidgen`
    docker run --rm -e KONGURL_SERVER=kong --network=${PROXY_NETWORK_ID} --entrypoint "" \
           -v ${WORK_DIR}:/keys ${PROXY_IMAGE} /edgex/secrets-config proxy \
           adduser --token-type jwt --id ${ID} --algorithm ES256 --public_key /keys/ec256.pub \
           --user testinguser > /dev/null
    #create a JWT
    docker run --rm -e KONGURL_SERVER=kong --network=${PROXY_NETWORK_ID} --entrypoint "" \
           -v ${WORK_DIR}:/keys ${PROXY_IMAGE} /edgex/secrets-config proxy \
           jwt --algorithm ES256 --id ${ID} --private_key /keys/ec256.key
  ;;
  -userdel)
    docker run --rm -e KONGURL_SERVER=kong --network=${PROXY_NETWORK_ID} --entrypoint "" \
           -v ${WORK_DIR}:/keys ${PROXY_IMAGE} /edgex/secrets-config proxy \
           deluser --user testinguser
  ;;
  *)
    exit 0
  ;;
esac

