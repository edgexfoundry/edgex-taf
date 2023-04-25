#!/bin/bash -e
 

help()
{
    printf --  "Run TAF tests using snaps\n\n"
    printf --  "Usage:\n"
    printf --  "  run-tests.sh [OPTIONS]\n\n"
    printf --  "Available options:\n"
    printf -- "  -s [filename] Test using specified local edgexfoundry snap [instead of --edge]\n"
    printf -- "  -a [filename] Test using specified local edgex-app-service-configurable snap [instead of --edge]\n"
    printf -- "  -t [test]     Run functional tests [all/app-service/core-command/core-data/core-metadata/support-notifications/support-scheduler/system-agent]\n"
    printf -- "  -d [test]     Run device tests [all/device-virtual/device-modbus]\n"
    printf -- "  -n            Do not use security/API gateway\n"
    printf -- "  -i            Run integration tests\n"
    exit 0 

}

if [[ $# -eq 0 ]]; then
    help
fi
 

if [ "$(id -u)" != "0" ]; then
    echo "script must be run as root"
    exit 1
fi

# load the utils
# shellcheck source=/dev/null 

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source "$SCRIPT_DIR/snap-taf-tests.sh"
 

export ARCH=x86_64
export SECURITY_SERVICE_NEEDED=true

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            help
             ;;
        -s)
            export LOCAL_SNAP="$2" # used in deploy-edgex
            shift # past argument
            shift # past value
            ;;
        -a)
            export LOCAL_ASC_SNAP="$2" # used in deploy-edgex
            shift # past argument
            shift # past value
            ;;
        -d)
            DEVICE_TESTS="$2"
            shift # past argument
            shift # past value
            ;;
       -t|--test)
            FUNCTIONAL_TESTS="$2"
            shift # past argument
            shift # past value
            ;;
        -n)
            export SECURITY_SERVICE_NEEDED=false
            shift # past argument     
            ;;
        -i)
            INTEGRATION_TESTS=1
            shift # past argument            
            ;;
        
        *)    # unknown option
            help 
            ;;
    esac
done 

 



# constants
BASEDIR=$(pwd)
export WORK_DIR=${BASEDIR}/../../../..
cd ${WORK_DIR}

snap_taf_install_prerequisites

snap_taf_enable_snap_testing
snap_taf_deploy_edgex

snap_taf_update_consul


 if [ $SECURITY_SERVICE_NEEDED = "false" ]; then
    sudo snap set edgexfoundry security-proxy=off
 fi

if [ ! -z "$FUNCTIONAL_TESTS" ]; then
    echo "INFO:snap-TAF: running API functional tests: $FUNCTIONAL_TESTS ..."
    snap_taf_run_functional_tests $FUNCTIONAL_TESTS
fi

if [ ! -z "$DEVICE_TESTS" ]; then

    if [ $DEVICE_TESTS = "all" ]; then
        DEVICE_TESTS="device-virtual device-modbus"
    fi

    echo "INFO:snap-TAF: running API device tests: $DEVICE_TESTS ..."
    snap_taf_run_functional_device_tests $V2_DEVICE_TESTS
fi


if [ ! -z "$INTEGRATION_TESTS" ]; then
    echo "INFO:snap-TAF: running integration tests"
    snap_taf_run_integration_tests MessageBus=redis redis-integration-test.html
    
    # do a new clean install 
    snap_taf_shutdown
    snap_taf_deploy_edgex

    # then switch to a mqtt message bus and run further tests
    snap_set_messagebus_to_mqtt

    snap_taf_run_integration_tests MessageBus=mqtt mqtt-integration-test.html

fi

snap_taf_shutdown
