import os

WORK_DIR = os.getenv('WORK_DIR')
SERVICE_NAME = "device-modbus"
DEVICE_PROFILE_NAME = "test-device-profile"
SIMULATOR_HOST = "192.168.x.x"
MQTT_BROKER_IP = "192.168.x.x"
SLEEP_INTERVAL = 60
DEVICE_INCREMENT = 10
THRESHOLD_CPU_UTILIZATION = 100
THRESHOLD_MEMORY_UTILIZATION = 80
THRESHOLD_MEMORY_USAGE_GROWTH = 20
SIMULATOR_NUMBER = 1000
STARTING_PORT = 10000
# PROC_PATH is the path of process information pseudo-filesystem
PROC_PATH = "/proc"
