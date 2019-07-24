<!--

 Copyright (C) 2019 Intel Corporation

 SPDX-License-Identifier: Apache-2.0

-->

This directory is used for keeping configurations that are common to test cases.
The config files store the key/value pairs in pre-defined sections.

The sections names are determined once the Solution architecture and TAF architecture details are known.

In TAF, we have 4 types of config files
1. Profile.cfg
2. common.robot
3. default.cfg
4. Platform.cfg


**profile.cfg** specifies the different platform flavors available for test execution.
For instance, all the tests need to be regressed with one or more the browser types and/or with one or more processors.
This cfg file have an associated python file to parse the cfg file into variables.

Each key can contain only one value. for each variation, seperate profile.cfg need to be generated.

```bash
browser=Chrome
#OS-> ubuntu, etc
os=ubuntu
#processor-> IA32, ARM
processor=IA32
#connectivity ->3g, wired etc
connectivity=wired
#Time out
selenium_wait=5
```

**common.robot** contains the PATH and common variable names that are needed for robot test execution.
Each robot file under testScenarios/UC_<demo> must import common.robot.

**default.cfg** is the defacto configuration file incase there is no specific config file inside the testScenario/UC_<UseCaseName>.

**platform.cfg** contains all platform specific configurations key/value pair like login info, timeout , connectivity & port info, cloud info that are
 needed to perform testing. These variables are grouped in to sections that are
 determined based on the solution architecture. These variables are used by the
 python testcase apps.

 Sample platform.cfg

```bash
[DEFAULT]
TestHostIP=
ApplianceIP=

[HTTP]
http_timeout=

[Login]
url_proto=http
url_base=127.0.0.1
api2_port=None
broker_port=8888
docker_port=
broker_secure=True
request_connect_timeout=60.05
request_read_timeout=60.05
production=False
startWebHook=False

#[CloudStore]
Provider=AWS
URL=https://
configFile=

```
