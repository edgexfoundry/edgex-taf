# Suite: 1_resource_usage
# Prior release (GENEVA) image size (MB)
CONSUL_IMAGE = 139.26
DATA_IMAGE = 23.80
METADATA_IMAGE = 14.42
COMMAND_IMAGE = 12.99
NOTIFICATIONS_IMAGE = 14.45
SCHEDULER_IMAGE = 13.12
APP_SERVICE_CONFIGURABLE_IMAGE = 29.84
SYS_MGMT_AGENT_IMAGE = 284
DEVICE_VIRTUAL_IMAGE = 20.84
DEVICE_REST_IMAGE = 19.8
KUIPER_IMAGE = 0
REDIS_IMAGE = 29.78

# Prior release (GENEVA) binary size (MB)
CONSUL_BINARY = 0
DATA_BINARY = 15.65
METADATA_BINARY = 14.41
COMMAND_BINARY = 12.98
NOTIFICATIONS_BINARY = 13.12
SCHEDULER_BINARY = 13.12
APP_SERVICE_CONFIGURABLE_BINARY = 21.18
SYS_MGMT_AGENT_BINARY = 10.08
DEVICE_VIRTUAL_BINARY = 15.23
DEVICE_REST_BINARY = 14.17
KUIPER_BINARY = 0
REDIS_BINARY = 0

# Footprint threshold value
# ex. 1.2 = prior release + 20%
FOOTPRINT_THRESHOLD = 1.2

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
PING_RES_THRESHOLD = 100


# Suite: 5_event_exported_time
# Loop time for sending ping request
EXPORTED_LOOP_TIMES = 10

# Ping response time threshold value (in milliseconds)
EXPORT_TIME_THRESHOLD = 1200
