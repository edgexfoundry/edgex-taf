LOG_LEVEL = "INFO"

# Deploy type: docker, manual
DEPLOY_TYPE = "docker"
SERVICE_STARTUP_RECHECK_TIMES = 5
SERVICE_STARTUP_WAIT_TIME = 3

# EdgeX host
BASE_URL = "localhost"

# Device service for testing
DEVICE_SERVICE_NAME = "device-random"
DEVICE_SERVICE_EDGEX_NAME= "edgex-device-random"
DEVICE_SERVICE_PORT = 49988

# Service port
CORE_DATA_PORT = 48080
CORE_METADATA_PORT = 48081
CORE_COMMAND_PORT = 48082
SUPPORT_LOGGING_PORT = 48061
SUPPORT_NOTIFICATION_PORT = 48060
SUPPORT_SCHEDULER_PORT = 48085
SUPPORT_RULESENGINE_PORT = 48075
EXPORT_CLIENT_PORT = 48071
EXPORT_DISTRO_PORT = 48070
REGISTRY_PORT = 8500

SUPPORTED_DATA_TYPES = [
    #     Integer
    {"dataType": "INT8", "commandName": "GenerateDeviceValue_Int8_RW", "readingName": "DeviceValue_Int8_RW", "readWrite": "RW"},
    {"dataType": "INT8", "commandName": "GenerateDeviceValue_Int8_R", "readingName": "DeviceValue_Int8_R", "readWrite": "R"},
    {"dataType": "INT8", "commandName": "GenerateDeviceValue_Int8_W", "readingName": "DeviceValue_Int8_W", "readWrite": "W"},
    {"dataType": "INT16", "commandName": "GenerateDeviceValue_Int16_RW", "readingName": "DeviceValue_Int16_RW", "readWrite": "RW"},
    {"dataType": "INT16", "commandName": "GenerateDeviceValue_Int16_R", "readingName": "DeviceValue_Int16_R", "readWrite": "R"},
    {"dataType": "INT16", "commandName": "GenerateDeviceValue_Int16_W", "readingName": "DeviceValue_Int16_W", "readWrite": "W"},
    {"dataType": "INT32", "commandName": "GenerateDeviceValue_Int32_RW", "readingName": "DeviceValue_Int32_RW", "readWrite": "RW"},
    {"dataType": "INT32", "commandName": "GenerateDeviceValue_Int32_R", "readingName": "DeviceValue_Int32_R", "readWrite": "R"},
    {"dataType": "INT32", "commandName": "GenerateDeviceValue_Int32_W", "readingName": "DeviceValue_Int32_W", "readWrite": "W"},
]