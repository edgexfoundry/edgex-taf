## Running Performance Tests with Docker Compose
For custmization, provide the docker-compose file (docker-compose.yml) and app-service configuration file (app_conf.yaml) in the docker_compose directory.

### 1. Device/Simulator - Simulator Machine
Skip it, if using real device
- Navigate to the performance directory:
  ```sh
  cd performance
  ```
- Deploy the simulator service:
  ```sh
  sh docker_compose/performance-setup.sh simulator
  ```

### 2. Export Server and Reporting Service Machine
- Navigate to the performance directory:
  ```sh
  cd performance
  ```
- Deploy the report-server services:
  ```sh
  sh docker_compose/performance-setup.sh report-server
  ```

### 3. EdgeX Platform - Test Target Machine
- **Update Configuration File:**
  - Edit `performance/config.env` file:
    - Update `SIMULATOR_IP` and `REPORT_SERVER_IP` if running on different machines.
    - Update `TIME_NUMBER` and `TIME_UNIT` to specify the duration of data retrieval.
    - Update `CRONTAB_MIN` to specify the interval (in minutes) for running a single instance of system metrics collection.
- **Install Dependencies for Report Generation:**
  - Install `jq`:
    ```sh
    sudo apt install jq
    ```
  - Install required Python modules:
    ```sh
    pip3 install influxdb_client matplotlib seaborn python-dotenv paho-mqtt
    ```
- **Set up `Sysstat` to collect system metrics reports.** For details, refer to [Setup Sysstat](setup-sysstat.md).
- **Deploy Central Services:**
  - Deploy central services:
    ```sh
    sh docker_compose/performance-setup.sh edgex
    ```

**Note:** The deployment script will update the InfluxDB host and InfluxDB token in the `telegraf.conf` file.

## Generating the Report
- The command:
  ```sh
  sh {command_dir}/performance-setup.sh edgex
  ```
  includes:
  ```sh
  python3 generate-report.py &
  ```
- To re-generate the report, run the command as a background process:
  ```sh
  python3 generate-report.py &
  ```

- Wait for the duration specified by `{TIME_NUMBER}{TIME_UNIT}`. The report (e.g., `report-{timestamp}.png`) and CSV files will be generated automatically in the `performance/reports` directory.
- View the system metrics report using [SAR Chart](setup-sysstat.md#view-report-using-sar-charts).

## Shutting Down Services
- Navigate to the performance directory:
  ```sh
  cd performance
  ```
- Stop all services:
  ```sh
  sh {command_dir}/performance-setup.sh shutdown
  ```

**Note:** The `command_dir` varies based on whether deployment was done via `docker compose` or `edgecentral`.
