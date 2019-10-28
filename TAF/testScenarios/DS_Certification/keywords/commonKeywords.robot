*** Variables ***
&{SERVICE_NAME_MAPPING}       consul=edgex-core-consul    data=edgex-core-data         metadata=edgex-core-metadata     device-modbus=edgex-device-modbus       device-virtual=edgex-device-virtual         device-random=edgex-device-random

*** Settings ***
Documentation  Device Readings - Query commands
Library   OperatingSystem
Library   Collections
Library   String


*** Keywords ***
Skip write only commands
    @{data_types_skip_write_only}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
    \     Continue For Loop If   '${item["readWrite"]}' == 'W'
    \     Append To List    ${data_types_skip_write_only}    ${item}
    [Return]   ${data_types_skip_write_only}

Skip read only commands
    @{data_types_skip_read_only}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
    \     Continue For Loop If   '${item["readWrite"]}' == 'R'
    \     Append To List    ${data_types_skip_read_only}    ${item}
    [Return]  ${data_types_skip_read_only}

Get reading value with data type "${data_type}"
    # Boolean
    run keyword and return if  '${data_type}' == 'BOOL'  evaluate  random.choice(['True', 'False'])  modules=random
    # STRING
    run keyword and return if  '${data_type}' == 'STRING'  Generate Random String  10  [LETTERS]
    # FLOAT
    run keyword and return if  '${data_type}' == 'FLOAT32'  evaluate  random.uniform(1.1, 1.9)  modules=random
    run keyword and return if  '${data_type}' == 'FLOAT64'  evaluate  random.uniform(1.1, 1.9)  modules=random
    # INT
    run keyword and return if  '${data_type}' == 'INT8'  evaluate  random.randint(-128, 127)  modules=random
    run keyword and return if  '${data_type}' == 'INT16'  evaluate  random.randint(-32768, 32767)  modules=random
    run keyword and return if  '${data_type}' == 'INT32'  evaluate  random.randint(-2147483648, 2147483647)  modules=random
    run keyword and return if  '${data_type}' == 'INT64'  evaluate  random.randint(-9223372036854775808, 9223372036854775807)  modules=random
    # UINT
    run keyword and return if  '${data_type}' == 'UINT8'  evaluate  random.randint(0, 255)  modules=random
    run keyword and return if  '${data_type}' == 'UINT16'  evaluate  random.randint(0, 65535)  modules=random
    run keyword and return if  '${data_type}' == 'UINT32'  evaluate  random.randint(0, 4294967295)  modules=random
    run keyword and return if  '${data_type}' == 'UINT64'  evaluate  random.randint(0, 18446744073709551615)  modules=random

