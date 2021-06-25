
<a name="EdgeX Test Automation (found in edgex-taf) Changelog"></a>
## EdgeX Test Automation
[Github repository](https://github.com/edgexfoundry/edgex-taf)

## [v2.0.0] Ireland - 2021-06-30  (Not Compatible with 1.x releases)

### Features ✨
- Add changing `device-modbus:` to `edgex-device-modbus:` and setting URL to master ([#6610122](https://github.com/edgexfoundry/edgex-taf/commits/6610122))
- Fixed TAF Perf to proply also pull the standard compose file ([#8d68d5e](https://github.com/edgexfoundry/edgex-taf/commits/8d68d5e))
- Switch to use edgex-mqtt-broker and removed EXPORT_HOST_PLACE_HOLDER replacement ([#405d454](https://github.com/edgexfoundry/edgex-taf/commits/405d454))
- Removed unneed sed subsitutions ([#2e10d08](https://github.com/edgexfoundry/edgex-taf/commits/2e10d08))
- Changed output of docker-compose-end-mqtt.yaml to docker-compose-mqtt.yaml ([#dfbd838](https://github.com/edgexfoundry/edgex-taf/commits/dfbd838))
- Removed references to the ${ARCH}.env files ([#6f07626](https://github.com/edgexfoundry/edgex-taf/commits/6f07626))
- Add Modbus scalability testing ([#b80dbeb](https://github.com/edgexfoundry/edgex-taf/commits/b80dbeb))
### Bug Fixes 🐛
- Remove retry items of SecretStore config and update secret path - go-mod-bootstrap has implemented the addition of prefix /v1/secret/edgex/ for the Path property of SecretStore config section, so we just use the service specific secret path in Toml files - also retry related item in SecretStore config no longer needed and hence removed ([#20a6503](https://github.com/edgexfoundry/edgex-taf/commits/20a6503))
- Update service key name in token path to new name ([#f998962](https://github.com/edgexfoundry/edgex-taf/commits/f998962))
- Update gateway token generation ([#038becc](https://github.com/edgexfoundry/edgex-taf/commits/038becc))
### Code Refactoring ♻
- Update container names for those recently changed ([#b2ebc50](https://github.com/edgexfoundry/edgex-taf/commits/b2ebc50))
- Update the route names to the new service key based names ([#0410181](https://github.com/edgexfoundry/edgex-taf/commits/0410181))
- Update to use new port assignments ([#c750538](https://github.com/edgexfoundry/edgex-taf/commits/c750538))
- Additional changes from PR comments ([#c8c4eb1](https://github.com/edgexfoundry/edgex-taf/commits/c8c4eb1))
- Update for service key name changes to remove edgex- prefix ([#598cda5](https://github.com/edgexfoundry/edgex-taf/commits/598cda5))
- Change delpoy-edgex.sh to deplaoy all security services together ([#8b12dd4](https://github.com/edgexfoundry/edgex-taf/commits/8b12dd4))
- Change gateway port to 8100 ([#c60127f](https://github.com/edgexfoundry/edgex-taf/commits/c60127f))
- Update App Service tests for change in service key ([#faf4730](https://github.com/edgexfoundry/edgex-taf/commits/faf4730))
- Switch to 2.0 Consul path ([#df0134c](https://github.com/edgexfoundry/edgex-taf/commits/df0134c))
- Update docker scripts to pull compose files from new location ([#11b0e2c](https://github.com/edgexfoundry/edgex-taf/commits/11b0e2c))
- Rename SetOutputData to SetResponseData ([#4af9c12](https://github.com/edgexfoundry/edgex-taf/commits/4af9c12))
- App Service Trigger tests for function configuration changes ([#ce9915b](https://github.com/edgexfoundry/edgex-taf/commits/ce9915b))
- Update scripts to pull compose files from edgex-compose repo ([#f25c686](https://github.com/edgexfoundry/edgex-taf/commits/f25c686))
- Use new nightly build TAF compose files ([#186834e](https://github.com/edgexfoundry/edgex-taf/commits/186834e))
### Documentation 📖
- Add badges to readme ([#1f5bfad](https://github.com/edgexfoundry/edgex-taf/commits/1f5bfad))
### Reverts
- Add scheduler tests to SmokeTest for kong issue
- refactor: Change gateway port to 8100
- Change image url to use dockerhub hanoi release

<a name="v1.3.0"></a>
## [v1.3.0] - 2020-11-20
### Bug Fixes 🐛
- Fixed links to nightly-build compose files to point to edgexfoundry master ([#a5ef11f](https://github.com/edgexfoundry/edgex-taf/commits/a5ef11f))
### Code Refactoring ♻
- Adjust URL path to base compose file now under new compose-generator ([#ec3e15f](https://github.com/edgexfoundry/edgex-taf/commits/ec3e15f))
- renamed existing common.env to common-taf.env to avoid name conflict ([#bb20039](https://github.com/edgexfoundry/edgex-taf/commits/bb20039))
- added changing the database service name to `database` in previous compose files. ([#c5d729e](https://github.com/edgexfoundry/edgex-taf/commits/c5d729e))
- Replace `redis` service name with `database` so deploy works ([#40d51a5](https://github.com/edgexfoundry/edgex-taf/commits/40d51a5))
- Updated scripts to use curl and pull from new `source` folder. ([#84241da](https://github.com/edgexfoundry/edgex-taf/commits/84241da))
- Fixed typo if "-arm64" ([#105a52f](https://github.com/edgexfoundry/edgex-taf/commits/105a52f))
- Updated get-compose-file-backward.sh to use base compose file from nightly-build ([#87a1ec1](https://github.com/edgexfoundry/edgex-taf/commits/87a1ec1))
- Update scripts to handle chnage to multi-file compose files. ([#b35cc52](https://github.com/edgexfoundry/edgex-taf/commits/b35cc52))
