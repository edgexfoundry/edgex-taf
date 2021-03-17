# Collect performance metrics

### Prerequisites
Clone the edgex-taf project from EdgeX Foundry as a template:

``` bash
cd  /home/$USER
git clone https://github.com/edgexfoundry/edgex-taf.git
```

###  Variable configuration
Export the following variables

```
export WORK_DIR=/home/$USER/edgex-taf
```

### Run scripts
```
cd $WORK_DIR/TAF/utils/scripts/docker
sh exec_performance_metrics.sh ${USE_ARCH}
# ex. sh exec_performance_metrics.sh x86_64
```

### View detail execution reports
1. Open report file from ${WORK_DIR}/TAF/testArtifacts/reports/edgex/log.html
2. Expend test suite 9_summary_reports.summary_reports
3. See the following image as example.
![image](./images/perf-metrics-detail-report.png)

### View summary reports
1. Open performance-metrics.html file from ${WORK_DIR}/TAF/testArtifacts/reports/edgex
2. See the following image as example.
![image](./images/perf-metrics-summary-report.png)
