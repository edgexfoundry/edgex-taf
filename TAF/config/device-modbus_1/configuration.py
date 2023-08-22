import os

# Service for testing
SERVICE_NAME = "device-modbus_1"
PREFIX = "Modbus"

SECURITY_SERVICE_NEEDED = os.getenv("SECURITY_SERVICE_NEEDED")
if SECURITY_SERVICE_NEEDED == 'true':
    SERVICE_PORT = "8443/device-modbus_1"
else:
    SERVICE_PORT = 59911
