# EdgeX TAF

ITAF Architecture Choices:

- Well -defined Test Code Structure.
- Test application code that narrates the use case scenarios are written using human-readable syntax with ROBOT tool.
- Abstraction of test case code from test application code. Test case code are ROBOT Keywords defined in Python/ROBOT.
- Separation of configuration data from test case application code. Configuration data can be in several formats including JSON, YAML, .cfg etc.
- Separate test logs/reports from test application code.
- Common test code utilities that are documented and catalogued for cross workgroup group reuse.
- Embrace other test aid tools and test scope like JMETER, Selenium, postman, console-cli etc.
- Integration with Jenkins facilitated by TAF Manager

## Overview

![image](./images/edgex-taf-overview.png)

- TAF(https://github.com/edgexfoundry/edgex-taf) provides a well-defined project structure for the configuration and test cases, test scripts, and test report
- TAF Common(https://github.com/edgexfoundry/edgex-taf-common) provides a place for reusable scripts and Robotframework usage
- All testing target and dependency should provide the docker image or installation script for automation testing job. For example, device-modbus testing should provide device-modbus docker image and Modbus device simulator docker image or installation script.
- TAF should provide xUnit format testing results which Jenkins server can generate statistics.
    - https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#xunit-compatible-result-file
    - https://plugins.jenkins.io/xunit
- TAF should provide HTML format testing result
    - https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#report-file


## Run TAF Testing
See [How to run tests on local](run-tests-on-local.md)

## Develop New Device Service Test Script
**Please ignore the step, if you don't need to develop new test for new device-service.**

To write the automation testing for virtual device service, complete the following steps:

### Prerequisites

1.  Clone the edgex-taf project from EdgeX Foundry as a template:

    ``` bash
    git clone https://github.com/edgexfoundry/edgex-taf.git
    ```

2. Install pre-request packages. Download pip3 and run this command:

    ``` bash
    sudo apt-get install python3-pip
    ```

3. Install TAF common:

    ``` bash
    git clone https://github.com/edgexfoundry/edgex-taf-common.git

    # Install dependency lib
    pip3 install -r ./edgex-taf-common/requirements.txt

    # Install edgex-taf-common as lib
    pip3 install ./edgex-taf-common
    ```

### Add configuration

1. Copy the default folder and rename to device-virtual:

    ```
    TAF/config
    ├── README.md
    ├── global_variables.py
    ├── default
    │   ├── configuration.py
    │   ├── configuration.toml
    │   └── sample_profile.yaml
    └── device-virtual
        ├── configuration.py
        ├── configuration.toml
        └── sample_profile.yaml
    ```

2. Modify properties for testing:

    ``` toml
    [TAF/config/device-virtual/configuration.py]

    SERVICE_NAME = "device-virtual"
    SERVICE_PORT = 59900
    ```

3. Provide the configuration.toml file and modify the ProfilesDir property value to "/custom-config":

    ```
    TAF/config
    └── device-virtual
        ├── configuration.toml

    [Device]
        ...
        ProfilesDir = "/custom-config"
    ```

4. Remove string data type because device-virtual only support boolean, float and integer:

    ```
    [TAF/config/device-virtual/configuration.py]

    SUPPORTED_DATA_TYPES = [
        #     Boolean
        ...
        #     Float
        ...
        #     Integer
        ...
        #     Unsigned Integer
        ...
    ]
    ```

5. Add the protocol properties with name same as ${SERVICE_NAME} on TAF/testData/core-metadata/device_protocol.json, the property key and value are base on the DS implementation::

    ``` json
    {
        "device-virtual": {
            "other": {
                "Address": "simple01",
                "Port": "300"
            }
        }
    }
    ```

6. Add the DS to the docker-compose File

    In this document, we deploy all services using docker, so we must add the docker images to the docker-compose file, as illustrated below:

    ``` yaml
    # TAF/utils/scripts/docker/device-service.yaml
    
      device-virtual:
        image: edgexfoundry/docker-device-virtual-go:master
        ports:
        - "59900:59900"
        container_name: edgex-device-virtual
        hostname: edgex-device-virtual
        networks:
          - edgex-network
        environment:
          REGISTRY_HOST: edgex-core-consul
          CLIENTS_CORE_DATA_HOST: edgex-core-data
          CLIENTS_CORE_METADATA_HOST: edgex-core-metadata
          Service_Host: edgex-device-virtual
        entrypoint: ["/device-virtual"]
        command: ["--registry","--confdir=${CONF_DIR}"]
        volumes:
          - ${WORK_DIR}/TAF/config/${PROFILE}:${CONF_DIR}:z
        depends_on:
          - consul
          - data
          - command
    ```
### Develop new test case

Put the ROBOT based Test Application code under "use case" folder prefixed with "UC_" in the `TAF/testScenarios` folder.  The robot test case must contain the Settings, Variables and Keywords, the example shown below:

``` bash    
*** Settings ***
Documentation    DS Ping Testing
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
Suite Setup      Setup Suite
Suite Teardown   Suite Teardown
    
*** Variables *** 
${SUITE}                  DS Ping Testing
${LOG_FILE_PATH}          ${WORK_DIR}/TAF/testArtifacts/logs/ds_ping.log
${DEVICE_SERVICE_URL}     http://localhost:${DEVICE_SERVICE_PORT}

*** Keywords ***
# Setup called once before all test cases.
Setup Suite
${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
Should Be True  ${status}  Failed Suite Setup
    
*** Test Cases ***
Test ping API
When Send GET request "/api/v1/ping" to "${DEVICE_SERVICE_URL}"
Then Status code "${REST_RES.status_code}" should be "200"
And Validate ${REST_RES.content} contains version element "1.1.0"
```

### Configuration Profiles

Edgex-taf defines the configuration folder separated by different profiles; the user can trigger the testing using the profile name:
    
```
    TAF/config
    ├── device-modbus
    └── device-random
```
    
For example, to run the DS testing for **device-random**:
    
``` bash
    python3 -m TUC -p device-random -u functionalTest/device-service/common
```
    
Or to run the DS testing for **device-modbus**:
    
``` bash
    python3 -m TUC -p device-modbus -u functionalTest/device-service/common
```

### How to use the configuration in the testing script

Define constant in the configuration.py:
    
``` python
#global_variables.py
    # EdgeX host
    BASE_URL = "localhost"
    
# configuration.py
    # Service for testing
    SERVICE_NAME = "device-virtual"
    SERVICE_PORT = 59900
```
    
Pass the constant to the robot file or python code:
    
``` python
# coreCommandAPI.robot
*** Variables ***
${coreCommandUrl}  http://${BASE_URL}:${CORE_COMMAND_PORT}
    
# startup_checker.py
conn = http.client.HTTPConnection(host=SettingsInfo().constant.BASE_URL, port=d["port"], timeout=httpConnTimeout)
```
    
Reference the following URL for more details on variables usage
https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#variable-priorities-and-scopes

### Python System Path Setup

We use the project root path as the system path. The python module names are **TAF**.

The usage for robot file is:  
```
# TAF/testScenarios/functionalTest/deploy-edgex.robot
   
*** Settings ***
Documentation    Deploy EdgeX
Library          TAF/testCaseModules/keywords/setup/setup_teardown.py
Library          TAF/testCaseModules/keywords/setup/edgex.py
```  
The usage for python script is illustrated below:
    
```
TAF/testCaseModules/keywords/setup/edgex.py
    
from TUC.data.SettingsInfo import SettingsInfo
import startup_checker as checker
```

## Use different deploy type
Default deploy type is set to "docker" which means deployment of Edgex using docker. 
To test instead using a snap deployment use

```
cd TAF/utils/scripts/snap
sudo ./run-tests.sh -t all
```

for information about the available options do

```
cd TAF/utils/scripts/snap
sudo ./run-tests.sh -h
```

