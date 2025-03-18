import os

SECURITY_SERVICE_NEEDED=os.getenv("SECURITY_SERVICE_NEEDED")
COMPOSE_IMAGE=os.getenv("COMPOSE_IMAGE")
ARCH=os.getenv("ARCH")

# Service Port
if SECURITY_SERVICE_NEEDED == 'true':
    DEVICE_REST_PORT = "8443/device-rest"
    DEVICE_VIRTUAL_PORT = "8443/device-virtual"
    APP_SERVICE_RULES_PORT = "8443/app-rules-engine"
else:
    DEVICE_REST_PORT = 59986
    DEVICE_VIRTUAL_PORT = 59900
    APP_SERVICE_RULES_PORT = 59701


# Suite: 1_resource_usage
# Prior release (ODESSA) image size (MB) for x86
KEEPER_IMAGE = 32.07 
DATA_IMAGE = 32.43
METADATA_IMAGE = 32.65
COMMAND_IMAGE = 27.91
NOTIFICATIONS_IMAGE = 51.65
SCHEDULER_IMAGE = 48.06
COMMON_CONFIG_IMAGE = 17.11
APP_SERVICE_CONFIGURABLE_IMAGE = 46.44
DEVICE_VIRTUAL_IMAGE = 41.81
DEVICE_REST_IMAGE = 41.81
KUIPER_IMAGE = 101.78
POSTGRES_IMAGE = 244.93
PROXY_IMAGE = 38.22
SECRETSTORE_IMAGE = 67.68
NGINX_IMAGE = 17.07
OPENBAO_IMAGE = 150.99
BOOTSTRAPPER_IMAGE = 20.31
SPIFFE_TOKEN_IMAGE = 46.92
SPIRE_AGENT_IMAGE = 194.88
SPIRE_CONFIG_IMAGE = 148.71 
SPIRE_SERVER_IMAGE = 149.50 

# Prior release (ODESSA) binary size (MB) for x86
KEEPER_BINARY = 0 
DATA_BINARY = 24.50
METADATA_BINARY = 24.72
COMMAND_BINARY = 19.98
NOTIFICATIONS_BINARY = 39.16
SCHEDULER_BINARY = 39.10
COMMON_CONFIG_BINARY = 9.17
APP_SERVICE_CONFIGURABLE_BINARY = 37.95
DEVICE_VIRTUAL_BINARY = 33.85
DEVICE_REST_BINARY = 33.86
KUIPER_BINARY = 0
POSTGRES_BINARY = 0
PROXY_BINARY = 0
SECRETSTORE_BINARY = 0
NGINX_BINARY = 0
OPENBAO_BINARY = 0
BOOTSTRAPPER_BINARY = 0
SPIFFE_TOKEN_BINARY = 0
SPIRE_AGENT_BINARY = 0
SPIRE_CONFIG_BINARY = 0
SPIRE_SERVER_BINARY = 0

# Prior release (ODESSA) image size (MB) for arm64
KEEPER_IMAGE_ARM64 = 32.53
DATA_IMAGE_ARM64 = 32.82
METADATA_IMAGE_ARM64 = 33.02
COMMAND_IMAGE_ARM64 = 28.36
NOTIFICATIONS_IMAGE_ARM64 = 52.00
SCHEDULER_IMAGE_ARM64 = 48.23
COMMON_CONFIG_IMAGE_ARM64 = 17.88
APP_SERVICE_CONFIGURABLE_IMAGE_ARM64 = 46.71
DEVICE_VIRTUAL_IMAGE_ARM64 = 42.02
DEVICE_REST_IMAGE_ARM64 = 42.01
KUIPER_IMAGE_ARM64 = 99.55
POSTGRES_IMAGE_ARM64 = 252.11
PROXY_IMAGE_ARM64 = 38.60
SECRETSTORE_IMAGE_ARM64 = 67.22
NGINX_IMAGE_ARM64 = 17.57
OPENBAO_IMAGE_ARM64 = 147.66
BOOTSTRAPPER_IMAGE_ARM64 = 21.07
SPIFFE_TOKEN_IMAGE_ARM64 = 47.86
SPIRE_AGENT_IMAGE_ARM64 = 187.20
SPIRE_CONFIG_IMAGE_ARM64 = 142.56
SPIRE_SERVER_IMAGE_ARM64 = 143.52

# Prior release (ODESSA) binary size (MB) for arm64
KEEPER_BINARY_ARM64 = 0
DATA_BINARY_ARM64 = 23.79
METADATA_BINARY_ARM64 =	23.99
COMMAND_BINARY_ARM64 = 19.33
NOTIFICATIONS_BINARY_ARM64 = 37.99 
SCHEDULER_BINARY_ARM64 = 38.08
COMMON_CONFIG_BINARY_ARM64 = 8.85
APP_SERVICE_CONFIGURABLE_BINARY_ARM64 = 37.03
DEVICE_VIRTUAL_BINARY_ARM64 = 32.96
DEVICE_REST_BINARY_ARM64 = 32.96

# Footprint threshold value
# ex. 1.5 = prior release + 50%
FOOTPRINT_THRESHOLD = 1.1

# Suite: 2_service_startup_time
# Retry setting to fetch service startup time
WAIT_TIME = 5
RETRY_TIMES = 5

# Startup time threshold value (in seconds)
STARTUP_TIME_THRESHOLD = 300

# Loop time for retrieving services startup time
STARTUP_TIME_LOOP_TIMES = 5


# Suite: 3_resource_usage_with_autoevent
# CPU threshold value (percentage)
CPU_USAGE_THRESHOLD = 50

# Memory threshold value (in MB)
MEM_USAGE_THRESHOLD = 300

# Loop time for retrieving CPU and Memory
GET_CPU_MEM_LOOP_TIMES = 10

# Interval time for retrieving CPU and Memory (in seconds)
GET_CPU_MEM_INTERVAL = 7


# Suite: 4_ping_response_time
# Loop time for sending ping request
PING_RES_LOOP_TIMES = 100

# Ping response time threshold value (in milliseconds)
if ARCH == "arm64":
    PING_RES_THRESHOLD = 400
else:
    PING_RES_THRESHOLD = 100


# Allow the failure times for ping response time over than threshold setting
ALLOWABLE_OUTLIER = 5


# Suite: 5_event_exported_time
# Loop time for retrieve mqtt events
EXPORTED_LOOP_TIMES = 10

# Export time threshold value (in milliseconds)
EXPORT_TIME_THRESHOLD = 1200

# Subscriber Wait Duration (in seconds)
SUBSCIBE_DURATION = 180
