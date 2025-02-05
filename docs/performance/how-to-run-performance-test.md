# How To Run Performance Test
You can perform the following steps on either the same machine or multiple machines.

1. Simulator Machine
    - Navigate to the performance directory: `cd edgex-taf/performance`
    - Deploy the simulator service by running the command: `sh performance-setup.sh simulator`

2. Report Server Machine
    - Navigate to the performance directory: `cd edgex-taf/performance`
    - Deploy the report-server services by running the command: `sh performance-setup.sh report-server`

3. EdgeX Services Machine
    - Update Configuration File:
      - Edit edgex-taf/performance/config.env file
        - Update the `SIMULATOR_IP` and `REPORT_SERVER_IP` if running on different machines.
        - Update the `TIME_NUMBER `and `TIME_UNIT` to specify the duration of data to retrieve.
        - Update the `CRONTAB_MIN` to specify the number of minutes for running a single instance of system metrics collection.
    - Install Dependencies for Report Generation:
      - Install jq command: `sudo apt install jq`
      - Install required Python modules: `pip3 install influxdb_client matplotlib seaborn python-dotenv paho-mqtt`
    - Set up `Sysstat` to collect system metrics reports. For details, please see [Setup Sysstat](setup-sysstat.md)
    - Deploy EdgeX Services
      - Deploy EdgeX services by running the command: `sh performance-setup.sh edgex`
   
    Note. Deploy EdgeX Service script will update the influxdb host and influx token to `telegraf.conf` file.

4. Generate the Report
   - The command: `sh performance-setup.sh edgex` includes the command `python3 generate-report.py &`
   - To re-generate the report, run the command `python3 generate-report.py &` as a background process to generate the report again.
   - Wait for the duration specified by `{TIME_NUMBER}{TIME_UNIT}`, and `report-{timestamp}.png` along with CSV files will be automatically generated in the `performance/reports` directory.
   - View system metrics report by [SAR Chart](setup-sysstat.md#view-report-using-sar-charts)

5. Shutdown Services
   - Navigate to the performance directory: `cd edgex-taf/performance`
   - Deploy the report-server services by running the command: `sh performance-setup.sh shutdown`
