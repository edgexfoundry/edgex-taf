<!--

 Copyright (C) 2019 Intel Corporation

 SPDX-License-Identifier: Apache-2.0

-->

# TAF Demo

TAF stands for Test Automation Framework.
It is used for automating end-to-end UI and API tests of a SW (Software) solution.
This README will walkthrough TAF-demo deployment and execution.

Please note this is only a reference implementation.

TAF contains the Test code for the demo. It references edgex-taf-Common->TUC(Test Utility Catalog) for common utilities.

**requirements.txt** contains the list of all the libraries used by the project

**updateme.sh** is a script that automates the installation of the prerequisites.

## Clone the repo
```bash
git clone --recurse-submodules https://github.com/edgexfoundry-holding/edgex-taf.git
```

## Install Pre-requisites
```bash
cd edgex-taf
sudo ./updateme.sh
```

## Execute TAF
```bash
cd TAF/testScenarios
python3 run.py -u <UC_DIRECTORY>
```