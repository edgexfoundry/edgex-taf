# Suite: 1_resource_usage
# Prior release (HANOI) image size (MB)
CONSUL_IMAGE = 133.54
DATA_IMAGE = 22.28
METADATA_IMAGE = 13.49
COMMAND_IMAGE = 11.41
NOTIFICATIONS_IMAGE = 12.92
SCHEDULER_IMAGE = 11.54
APP_SERVICE_CONFIGURABLE_IMAGE = 27.27
SYS_MGMT_AGENT_IMAGE = 270.33
DEVICE_VIRTUAL_IMAGE = 19.24
DEVICE_REST_IMAGE = 16.10
REDIS_IMAGE = 31.25

# Prior release (HANOI) binary size (MB)
CONSUL_BINARY = 0
DATA_BINARY = 14.38
METADATA_BINARY = 13.48
COMMAND_BINARY = 11.40
NOTIFICATIONS_BINARY = 11.54
SCHEDULER_BINARY = 11.53
APP_SERVICE_CONFIGURABLE_BINARY = 18.84
SYS_MGMT_AGENT_BINARY = 8.98
DEVICE_VIRTUAL_BINARY = 13.87
DEVICE_REST_BINARY = 10.76
REDIS_BINARY = 0

# Footprint threshold value
# ex. 1.5 = prior release + 50%
FOOTPRINT_THRESHOLD = 1.5

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

# Allow the failure times for ping response time over than threshold setting
ALLOWABLE_OUTLIER = 5


# Suite: 5_event_exported_time
# Loop time for sending ping request
EXPORTED_LOOP_TIMES = 10

# Export time threshold value (in milliseconds)
EXPORT_TIME_THRESHOLD = 1200
