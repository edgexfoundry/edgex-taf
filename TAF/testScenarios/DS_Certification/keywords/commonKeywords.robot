*** Variables ***
&{SERVICE_NAME_MAPPING}
...     consul=edgex-core-consul    data=edgex-core-data    metadata=edgex-core-metadata

*** Settings ***
Library   OperatingSystem
Library   Collections
Library   String
Library   DateTime


*** Keywords ***
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Demo Suite Setup

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

Skip data types BOOL and STRING only commands "${SUPPORTED_DATA}"
    @{data_types_skip_bool_string}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA}
    \     Continue For Loop If   '${item["dataType"]}' == 'BOOL' or '${item["dataType"]}' == 'STRING'
    \     Append To List    ${data_types_skip_bool_string}    ${item}
    [Return]  ${data_types_skip_bool_string}

Skip read only and write only commands "${SUPPORTED_DATA}"
    @{data_types_get_rw}=    Create List
    :FOR    ${item}    IN    @{SUPPORTED_DATA}
    \     Continue For Loop If   '${item["readWrite"]}' == 'R' or '${item["readWrite"]}' == 'W'
    \     Append To List    ${data_types_get_rw}    ${item}
    [Return]  ${data_types_get_rw}

Get reading value with data type "${data_type}"
    # Boolean
    run keyword and return if  '${data_type}' == 'BOOL'  evaluate  random.choice(['true', 'false'])  modules=random
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


Should return status code "200"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 200

Should return status code "400"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 400

Should return status code "404"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 404

Should return status code "423"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 423

Should return status code "500"
    ${resp}=  get environment variable  response
    Should be true    ${resp} == 500

Get milliseconds epoch time
    ${data}=  get current date
    ${current_epoch_time}=  convert date    ${data}  epoch
    ${millisec_epoch_time}=    evaluate   int(${current_epoch_time}*1000)
    [Return]  ${millisec_epoch_time}

