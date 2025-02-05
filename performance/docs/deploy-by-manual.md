# Manual Installation Guide for Test Environment Setup

It is possible to run the test services from this framework alongside an existing and already-running EdgeX environment. In this case it is important to first verify the following settings based on the [Installation Steps](#installation-steps):

1. **Device-Service Verification**
   - Confirm that `device-service` is correctly receiving data from the device (or simulator).  

2. **Export Service Configuration**
   - Ensure that `app-service` is exporting data to the Export Server's MQTT broker.
   - The Export Server must be set up with an MQTT Broker to calculate latency and throughput.

3. **Service Container Metrics Collection**
   - `Telegraf` (must be installed on the Test Target Machine).  
   - `InfluxDB` (can be installed on the Test Target Machine or a separate machine).  
   - Ensure both are installed and have a valid connection.

4. **Host Metrics Collection**
   - `sysstat` must be installed on the Test Target Machine.


---

## Installation Steps

### 1. Install MQTT Broker (Export Server) and InfluxDB (Reporting Service)
Use the following `docker compose` command to install MQTT Broker and InfluxDB.  
*(Skip this step if the services are already installed.)*

```sh
cd performance/compose_files
docker compose -f docker-compose-export.yml up -d
```

### 2. Install the Simulator
Use the following `docker compose` command to install the simulator.  
*(Skip this step if not using `device-modbus`, or if using a real device, or if the simulator is already installed.)*

```sh
export WORK_DIR=<<performance_root>>
cd performance/compose_files
docker compose -f docker-compose-simulators.yml up -d
```

### 3. Edit `config.env`
Modify the following settings based on your environment:

- **Modify `REPORT_SERVER_IP`**
  - Required if the Export Server and Test Target Machine are in different environments.
  
- **Modify `BROKER_PORT`**
  - Required if the `app-service` export MQTT port is not `1884`.

- **Modify `SIMULATOR_IP`** *(Skip if any of the following apply:)*
  - Not using `device-modbus` or a real device.
  - The simulator is already installed.
  - Not installed the simulator using `performance-setup.sh`.

- **Telegraf and InfluxDB Settings** *(Skip if manually configured.)*  
  - `REPORT_SERVER_IP`: Set to `influxdb` IP.  
  - `INFLUX_INIT_TOKEN`: Set to `influxdb` initial token.  
  - Run the following command to update the above data in `telegraf.conf`:

    ```sh
    sh influx_request.sh
    ```

- **Modify `TIME_NUMBER` and `TIME_UNIT`**  
  - Defines the duration for data collection for generating report.

- **Modify `CRONTAB_MIN`**  
  - Specifies the frequency of Test Target Machine system metrics collection. *(Skip if `sysstat` is manually installed.)*

### 4. Install Test Target Machine Services
*(Skip this step if EdgeX services are already installed. Instead, verify section 4.1.)*

```sh
export WORK_DIR=<<performance_root>>
export HOST_DOCKER_GROUP_ID=$(cat /etc/group | grep docker | cut -d : -f 3)

cd performance/compose_files
# For security test
docker compose -f docker-compose.yml -f docker-compose-extra.yml up -d

# For non-security test
docker compose -f docker-compose.yml -f docker-compose-extra-no-secty.yml up -d

```

#### 4.1 Configuration Verification

Ensure the following settings are completed:

- Services in `docker-compose.yml` are deployed.
- `sysstat` is installed.
- Device (or simulator) has the correct `device profile`.
- `app-service` configuration is correct.
   - Events must be exported to the **MQTT broker**.
- Ensure `InfluxDB` and `Telegraf` are properly connected.


### 5. Generate Reports
#### 5.1 Generate Service Metrics and Latency/Throughput Reports
You can generate report on one of machines, simulator machine, report and exporting server machine or Test Target machine.

**Note. Sync system time before generating the report if generating report is not on Test Target Machine, although the latency value might still be inaccurate**

1. Install Dependencies for Report Generation
  - Install `jq`:
    ```sh
    sudo apt install jq
    ```
  - Install required Python modules:
    ```sh
    pip3 install influxdb_client matplotlib seaborn python-dotenv paho-mqtt
    ```

2. Edit `config.env` the report is not generated on the Test Target Machine
Modify the following settings based on your environment:

- **Modify `REPORT_SERVER_IP`**
  - Required if the Export Server and Test Target Machine are in different environments.

- **Modify `BROKER_PORT`**
  - Required if the `app-service` export MQTT port is not `1884`.

- **Telegraf and InfluxDB Settings**
  - `REPORT_SERVER_IP`: Set to `influxdb` IP.
  - `INFLUX_INIT_TOKEN`: Set to `influxdb` initial token.
  - Run the following command to update the above data in `telegraf.conf`:

    ```sh
    sh influx_request.sh
    ```

- **Modify `TIME_NUMBER` and `TIME_UNIT`**
  - Defines the duration for data collection for generating report.

3. Generate Service Metrics and Latency/Throughput Reports
- Run the following command in the background:

    ```sh
    python3 generate-report.py &
    ```

- Service metrics and latency/throughput reports will be automatically generated after the duration specified in `TIME_NUMBER` and `TIME_UNIT`.

#### 5.2 Generate System Metrics Report

Refer to `setup-state.md` for [**View Report Using SAR Charts**][setup-state.md#view-report-using-sar-charts] instructions to generate the system metrics report.
