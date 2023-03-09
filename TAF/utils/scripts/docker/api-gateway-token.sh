#!/bin/sh

option=${1}
PROXY_IMAGE=$(docker inspect --format='{{.Config.Image}}' edgex-security-proxy-setup)
PROXY_NETWORK_ID=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}' edgex-security-proxy-setup)

# Command vars
USER="tafuser"

case ${option} in
  -useradd)
    password=$(docker run --rm -e "USER=${USER}" --network=${PROXY_NETWORK_ID} -v edgex_vault-config:/vault/config:ro -e SECRETSTORE_HOST=edgex-vault --entrypoint /edgex/secrets-config ${PROXY_IMAGE} proxy adduser --user ${USER} -useRootToken | jq -r '.password')
    vault_token=$(curl -ks "http://localhost:8200/v1/auth/userpass/login/${USER}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')
    id_token=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/token/${USER}" | jq -r '.data.token')
    echo "${id_token}"
  ;;
  -userdel)
    # Remove a user from proxy
    docker run --rm -e "USER=${USER}" --network=${PROXY_NETWORK_ID} -v edgex_vault-config:/vault/config:ro -e SECRETSTORE_HOST=edgex-vault --entrypoint /edgex/secrets-config ${PROXY_IMAGE} \
      proxy deluser --user ${USER} -useRootToken > /dev/null
  ;;
  *)
    exit 0
  ;;
esac
