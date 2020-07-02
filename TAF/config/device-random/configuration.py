# Service for testing
SERVICE_NAME = "device-random"
SERVICE_PORT = 49988

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