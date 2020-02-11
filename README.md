<!--

 Copyright (C) 2019 Intel Corporation
 Copyright (C) 2019 IOTech Ltd

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
git clone git@github.com:edgexfoundry/edgex-taf.git
```

## Install Pre-requisites
```bash
cd edgex-taf
git submodule init
git submodule update --remote
sudo ./updateme.sh
```

## Execute TAF
```bash
python3 edgex-taf-common/TAF-Manager/trigger/run.py -u '*' -p device-virtual
```

## Open the Test Reports
Open the test reports in the browser. For example, to open the virtual device service certification report, enter the following URL in the browser:
```
path/to/edgex-taf/TAF/testArtifacts/reports/edgex/report.html
```
