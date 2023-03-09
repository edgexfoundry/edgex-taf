#!/bin/bash

option=${1}
# Command vars
USER="tafuser"

. "$SCRIPT_DIR/snap-utils.sh"

snap_maybe_switch_asc_profile
 
case ${option} in
  -useradd)
    # Create new user, log in, and exchange for JWT
    password=$(edgexfoundry.secrets-config proxy adduser --user ${USER} --useRootToken | jq -r '.password')
    vault_token=$(curl -ks "http://localhost:8200/v1/auth/userpass/login/${username}" -d "{\"password\":\"${password}\"}" | jq -r '.auth.client_token')
    id_token=$(curl -ks -H "Authorization: Bearer ${vault_token}" "http://localhost:8200/v1/identity/oidc/token/${username}" | jq -r '.data.token')
    echo "${id_token}"
  ;;
  -userdel)
    # Remove a user from Kong
    edgexfoundry.secrets-config proxy deluser --user ${USER} --useRootToken > /dev/null 2>&1
  ;;
  *)
    exit 0
  ;;
esac


>&2 echo "INFO:snap-TAF: api-gateway-token done"
