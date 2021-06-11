*** Settings ***
Library   RequestsLibrary
Library   OperatingSystem
Library   Collections
Library   String
Library   DateTime
Library   yaml
Library   Process
Library   TAF/testCaseModules/keywords/setup/edgex.py
Library   TAF/testCaseModules/keywords/setup/setup_teardown.py

*** Variables ***
${default_response_time_threshold}  1200

*** Keywords ***
Setup Suite
   ${status} =  Suite Setup  ${SUITE}  ${LOG_FILE_PATH}  ${LOG_LEVEL}
   Should Be True  ${status}  Failed Suite Setup

Run Teardown Keywords
    Delete All Sessions  # Delete http or https request sessions
    Run Keyword if  $SECURITY_SERVICE_NEEDED == 'true'  Remove Token

Get All Read Commands
    @{data_types_skip_write_only}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
          Continue For Loop If   '${item["readWrite"]}' == 'W'
          Append To List    ${data_types_skip_write_only}    ${item}
    END
    [Return]   ${data_types_skip_write_only}

Skip read only commands
    @{data_types_skip_read_only}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
          Continue For Loop If   '${item["readWrite"]}' == 'R'
          Append To List    ${data_types_skip_read_only}    ${item}
    END
    [Return]  ${data_types_skip_read_only}

Get All Write Only Commands
    @{data_types_write_only}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
          Run Keyword If  '${item["readWrite"]}' == 'W'  Append To List    ${data_types_write_only}    ${item}
    END
    [Return]   ${data_types_write_only}

Get All Write Commands
    @{data_types_all_write}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA_TYPES}
          Run Keyword If  '${item["readWrite"]}' != 'R'  Append To List    ${data_types_all_write}    ${item}
    END
    [Return]   ${data_types_all_write}

Skip data types BOOL and STRING only commands "${SUPPORTED_DATA}"
    @{data_types_skip_bool_string}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA}
          Continue For Loop If   '${item["dataType"]}' == 'BOOL' or '${item["dataType"]}' == 'STRING'
          Append To List    ${data_types_skip_bool_string}    ${item}
    END
    [Return]  ${data_types_skip_bool_string}

Skip read only and write only commands "${SUPPORTED_DATA}"
    @{data_types_get_rw}=    Create List
    FOR    ${item}    IN    @{SUPPORTED_DATA}
          Continue For Loop If   '${item["readWrite"]}' == 'R' or '${item["readWrite"]}' == 'W'
          Append To List    ${data_types_get_rw}    ${item}
    END
    [Return]  ${data_types_get_rw}

Get reading value with data type "${data_type}"
    # Boolean
    run keyword and return if  '${data_type}' == 'BOOL'  evaluate  random.choice(['true', 'false'])  modules=random
    # STRING
    run keyword and return if  '${data_type}' == 'STRING'  Generate Random String  10  [LETTERS]
    # FLOAT
    run keyword and return if  '${data_type}' == 'FLOAT32'  evaluate  round(random.uniform(1.1, 1.9), 2)  modules=random
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

Get random "${value}" from "${list}"
    ${random}=  Evaluate  random.choice(@{list})  random
    ${random_value}=  convert to string  ${random}[${value}]
    [Return]  ${random_value}

Get "${property}" from multi-status item ${index}
    ${item_value}=  Set Variable  ${content}[${index}][${property}]
    Set Test Variable  ${item_value}  ${item_value}

Should return status code "${status_code}"
    Should be true  ${response} == ${status_code}

Should return Content-Type "${content_type}"
    Should be true  '${headers}' == '${content_type}'

Should contain "${element}"
    Should Not be empty  ${content}[${element}]

Response Time Should Be Less Than "${time_limit}"ms
    log  Response Time:${response_time}ms
    Should be true  ${time_limit} >= ${response_time}  Response Time Exceeded:${response_time}ms

Should Return Status Code "${status_code}" And ${element}
    Should return status code "${status_code}"
    Should contain "${element}"

apiVersion Should be ${API_VERSION}
    Should contain "apiVersion"
    Should be true  '${content}[apiVersion]' == '${API_VERSION}'

Item Index ${index} Should Contain Status Code "${status_code}"
    ${content_type}=  Evaluate  type($content).__name__
    ${content}=  Run keyword if  ${content_type} != list  Evaluate  json.loads('''${content}''')  json
    ...          ELSE  Set Variable  ${content}
    ${len}=  Get length  ${content}
    Set Test Variable  ${content}  ${content}
    Set Test Variable  ${content_len}  ${len}
    ${index}=  Run keyword if  "${index}" == "All"  Evaluate  list(range(0,${len}))
    ...        ELSE  Split String  ${index}  ,
    FOR  ${i}  IN  @{index}
        Should be true  ${content}[${i}][statusCode] == ${status_code}
    END

Item Index ${index} Should Contain Status Code "${status_code}" And ${element}
    Item Index ${index} Should Contain Status Code "${status_code}"
    ${index}=  Run keyword if  "${index}" == "All"  Evaluate  list(range(0,${content_len}))
    ...        ELSE  Split String  ${index}  ,
    FOR  ${i}  IN  @{index}
        ${key}=  Fetch From Right  ${element}  no${SPACE}
        Run keyword if  "no" in "${element}"  Dictionary Should Not Contain Key  ${content}[${i}]  ${key}
        ...  ELSE  Dictionary Should Contain Key  ${content}[${i}]  ${key}
    END

Get current milliseconds epoch time
    ${current_epoch_time}=  Get current epoch time
    ${millisec_epoch_time}=    evaluate   int(${current_epoch_time}*1000)
    [Return]  ${millisec_epoch_time}

Get current nanoseconds epoch time
    ${current_epoch_time}=  Get current epoch time
    ${nonosec_epoch_time}=    evaluate   int(${current_epoch_time}*1000*1000000)
    [Return]  ${nonosec_epoch_time}

Get current epoch time
    ${data}=  get current date
    ${current_epoch_time}=  convert date    ${data}  epoch
    [Return]  ${current_epoch_time}

Get current ISO 8601 time
    ${current_date}  get current date  UTC
    ${current_ISO_8601_time}  Convert Date  ${current_date}  result_format=%Y%m%dT%H%M%S
    [Return]  ${current_ISO_8601_time}

Catch logs for service "${service_name}" with keyword "${keyword}"
    ${current_timestamp}=  Get current epoch time
    ${log_timestamp}=  evaluate   int(${current_timestamp}-1)
    ${service_log}=  Get service logs since timestamp  ${service_name}  ${log_timestamp}
    log  ${service_log}
    ${return_log}=  Get Lines Containing String  str(${service_log})  ${keyword}
    [Return]  ${return_log}

Found "${keyword}" in service "${service_name}" log
    ${return_log}=  Catch logs for service "${service_name}" with keyword "${keyword}"
    Should Not Be Empty  ${return_log}

Get Token
    ${jwt_token} =  Access Token  -useradd
    Should Not Be Empty  ${jwt_token}
    Set Global Variable  ${jwt_token}  ${jwt_token}

Remove Token
    ${jwt_token} =  Access Token  -userdel
    Should Be Empty  ${jwt_token}
    Set Global Variable  ${jwt_token}  ${EMPTY}

Load data file "${json_file}" and get variable "${use_variable}"
    ${json_data}=  Get File  ${WORK_DIR}/TAF/testData/${json_file}  encoding=UTF-8
    ${json_string}=  Evaluate  json.loads(r'''${json_data}''')  json
    [Return]    ${json_string}[${use_variable}]

Load yaml file "${yaml_file}" and convert to dictionary
    ${yaml_data}=  Get Binary File  ${WORK_DIR}/TAF/testData/${yaml_file}
    ${dict}=  yaml.Safe Load  ${yaml_data}
    [Return]  ${dict}

Set Response to Test Variables
    [Arguments]  ${resp}
    Set suite variable  ${response}  ${resp.status_code}
    ${elapsed}=  Evaluate   int(${resp.elapsed.total_seconds()}*1000)
    Set suite variable  ${response_time}  ${elapsed}
    ${headers}=  Run keyword if  'Content-Type' in ${resp.headers}  Set variable  ${resp.headers}[Content-Type]
    ...          ELSE  Set variable  None
    Set suite variable  ${headers}  ${headers}
    ${status}  ${value}=  Run Keyword And Ignore Error  Run Keyword If  '${headers}' == 'application/json'
    ...                                                 Evaluate  json.loads(r'''${resp.content}''')  json
    ...                                                 ELSE  Set variable  ${resp.content}
    Run Keyword If  '${status}' == 'PASS'   Set suite variable  ${content}  ${value}
    # when fail to deserialize json response content
    ...       ELSE  Set suite variable  ${content}  ${resp.content}

Query Ping
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Ping  url=${url}  disable_warnings=true
    ${resp}=  GET On Session  Ping  api/${API_VERSION}/ping  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query Config
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Config  url=${url}  disable_warnings=true
    ${resp}=  GET On Session  Config  api/${API_VERSION}/config  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query Version
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Version  url=${url}  disable_warnings=true
    ${resp}=  GET On Session  Version  api/${API_VERSION}/version  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Query Metrics
    ${headers}=  Create Dictionary  Authorization=Bearer ${jwt_token}
    Create Session  Metrics  url=${url}  disable_warnings=true
    ${resp}=  GET On Session  Metrics  api/${API_VERSION}/metrics  headers=${headers}  expected_status=200
    Set Response to Test Variables  ${resp}

Update Service Configuration On Consul
    [Arguments]  ${path}  ${value}
    ${consul_token}  Run Keyword If  $SECURITY_SERVICE_NEEDED == 'true'  Get Consul Token
    ${headers}=  Create Dictionary  X-Consul-Token=${consul_token}
    ${url}  Set Variable  http://${BASE_URL}:${REGISTRY_PORT}
    Create Session  Consul  url=${url}  disable_warnings=true
    ${resp}=  PUT On Session  Consul  ${path}  data=${value}  headers=${headers}  expected_status=200

Get Consul Token
    ${command}  Set Variable  docker exec edgex-core-consul cat /tmp/edgex/secrets/consul-acl-token/bootstrap_token.json
    ${result}  Run Process  ${command}  shell=True  output_encoding=UTF-8
    ${token}  Evaluate  json.loads('''${result.stdout}''')  json
    [Return]  ${token}[SecretID]
