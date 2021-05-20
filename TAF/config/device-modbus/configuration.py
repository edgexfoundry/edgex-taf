import os

# Service for testing
SERVICE_NAME = "device-modbus"
PREFIX = "Modbus"

SECURITY_SERVICE_NEEDED = os.getenv("SECURITY_SERVICE_NEEDED")
if SECURITY_SERVICE_NEEDED == 'true':
    SERVICE_PORT = "8443/modbusdevice"
else:
    SERVICE_PORT = 59901

SUPPORTED_DATA_TYPES = [
    #     Boolean
    {"dataType": "BOOL", "commandName": "Modbus_GenerateDeviceValue_Boolean_RW", "readingName": "Modbus_DeviceValue_Boolean_RW", "readWrite": "RW"},
    {"dataType": "BOOL", "commandName": "Modbus_GenerateDeviceValue_Boolean_R", "readingName": "Modbus_DeviceValue_Boolean_R", "readWrite": "R"},
    {"dataType": "BOOL", "commandName": "Modbus_GenerateDeviceValue_Boolean_W", "readingName": "Modbus_DeviceValue_Boolean_W", "readWrite": "W"},
    #     Float
    {"dataType": "FLOAT32", "commandName": "Modbus_GenerateDeviceValue_Float32_RW", "readingName": "Modbus_DeviceValue_Float32_RW", "readWrite": "RW"},
    {"dataType": "FLOAT32", "commandName": "Modbus_GenerateDeviceValue_Float32_R", "readingName": "Modbus_DeviceValue_Float32_R", "readWrite": "R"},
    {"dataType": "FLOAT32", "commandName": "Modbus_GenerateDeviceValue_Float32_W", "readingName": "Modbus_DeviceValue_Float32_W", "readWrite": "W"},
    {"dataType": "FLOAT64", "commandName": "Modbus_GenerateDeviceValue_Float64_RW", "readingName": "Modbus_DeviceValue_Float64_RW", "readWrite": "RW"},
    {"dataType": "FLOAT64", "commandName": "Modbus_GenerateDeviceValue_Float64_R", "readingName": "Modbus_DeviceValue_Float64_R", "readWrite": "R"},
    {"dataType": "FLOAT64", "commandName": "Modbus_GenerateDeviceValue_Float64_W", "readingName": "Modbus_DeviceValue_Float64_W", "readWrite": "W"},
    #     Integer
    {"dataType": "INT16", "commandName": "Modbus_GenerateDeviceValue_INT16_RW", "readingName": "Modbus_DeviceValue_INT16_RW", "readWrite": "RW"},
    {"dataType": "INT16", "commandName": "Modbus_GenerateDeviceValue_INT16_R", "readingName": "Modbus_DeviceValue_INT16_R", "readWrite": "R"},
    {"dataType": "INT16", "commandName": "Modbus_GenerateDeviceValue_INT16_W", "readingName": "Modbus_DeviceValue_INT16_W", "readWrite": "W"},
    {"dataType": "INT32", "commandName": "Modbus_GenerateDeviceValue_INT32_RW", "readingName": "Modbus_DeviceValue_INT32_RW", "readWrite": "RW"},
    {"dataType": "INT32", "commandName": "Modbus_GenerateDeviceValue_INT32_R", "readingName": "Modbus_DeviceValue_INT32_R", "readWrite": "R"},
    {"dataType": "INT32", "commandName": "Modbus_GenerateDeviceValue_INT32_W", "readingName": "Modbus_DeviceValue_INT32_W", "readWrite": "W"},
    {"dataType": "INT64", "commandName": "Modbus_GenerateDeviceValue_INT64_RW", "readingName": "Modbus_DeviceValue_INT64_RW", "readWrite": "RW"},
    {"dataType": "INT64", "commandName": "Modbus_GenerateDeviceValue_INT64_R", "readingName": "Modbus_DeviceValue_INT64_R", "readWrite": "R"},
    {"dataType": "INT64", "commandName": "Modbus_GenerateDeviceValue_INT64_W", "readingName": "Modbus_DeviceValue_INT64_W", "readWrite": "W"},
    #     Unsigned Integer
    {"dataType": "UINT16", "commandName": "Modbus_GenerateDeviceValue_UINT16_RW", "readingName": "Modbus_DeviceValue_UINT16_RW", "readWrite": "RW"},
    {"dataType": "UINT16", "commandName": "Modbus_GenerateDeviceValue_UINT16_R", "readingName": "Modbus_DeviceValue_UINT16_R", "readWrite": "R"},
    {"dataType": "UINT16", "commandName": "Modbus_GenerateDeviceValue_UINT16_W", "readingName": "Modbus_DeviceValue_UINT16_W", "readWrite": "W"},
    {"dataType": "UINT32", "commandName": "Modbus_GenerateDeviceValue_UINT32_RW", "readingName": "Modbus_DeviceValue_UINT32_RW", "readWrite": "RW"},
    {"dataType": "UINT32", "commandName": "Modbus_GenerateDeviceValue_UINT32_R", "readingName": "Modbus_DeviceValue_UINT32_R", "readWrite": "R"},
    {"dataType": "UINT32", "commandName": "Modbus_GenerateDeviceValue_UINT32_W", "readingName": "Modbus_DeviceValue_UINT32_W", "readWrite": "W"},
    {"dataType": "UINT64", "commandName": "Modbus_GenerateDeviceValue_UINT64_RW", "readingName": "Modbus_DeviceValue_UINT64_RW", "readWrite": "RW"},
    {"dataType": "UINT64", "commandName": "Modbus_GenerateDeviceValue_UINT64_R", "readingName": "Modbus_DeviceValue_UINT64_R", "readWrite": "R"},
    {"dataType": "UINT64", "commandName": "Modbus_GenerateDeviceValue_UINT64_W", "readingName": "Modbus_DeviceValue_UINT64_W", "readWrite": "W"},
]
