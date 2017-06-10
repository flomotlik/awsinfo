load ../../awsinfo
load ../../test-helpers/bats-assert/load

LOG_STREAM_NAME_1=test-log-stream-$RANDOM
LOG_STREAM_NAME_2=test-log-stream-$RANDOM

LOG_MESSAGE_TIMESTAMP=$(($(date -u +%s)*1000))

create_log_message(){
    awsie $(stack_name) logs create-log-stream --log-group-name cf:AWSInfoTestLogGroup: --log-stream-name $1
    awsie $(stack_name) logs put-log-events --log-group-name cf:AWSInfoTestLogGroup: --log-stream-name $1 --log-events timestamp=$LOG_MESSAGE_TIMESTAMP,message=TestMessage-$2
}
setup(){
    deploy_stack
    create_log_message $LOG_STREAM_NAME_1 1
    create_log_message $LOG_STREAM_NAME_2 2
}

@test "getting log messages" {
    # Default Logging Setup
    run awsinfo logs InfoTestLogGroup
    assert_success
    assert_output -p "TestMessage-1"
    assert_output -p "TestMessage-2"
    assert_output -p "$LOG_STREAM_NAME_1"
    assert_output -p "$LOG_STREAM_NAME_2"
    assert_output -p "AWSInfoTestLogGroup"

    # Without LogStream
    run awsinfo logs -S InfoTestLogGroup
    assert_success
    assert_output -p "TestMessage"
    assert_output -p "AWSInfoTestLogGroup"
    refute_output -p "$LOG_STREAM_NAME_1"
    refute_output -p "$LOG_STREAM_NAME_2"

    # Without LogGroup
    run awsinfo logs -G -S InfoTestLogGroup
    assert_success
    assert_line "TestMessage-1"

    # Checking for log groups test message
    run awsinfo logs -G -S InfoTestLogGroup
    assert_success
    assert_line -n 0 -e "^Reading logs from index-bats-AWSInfoTestLogGroup-.*$"

    # Filtering messages
    run awsinfo logs -f "TestMessage-1" InfoTestLogGroup
    assert_success
    assert_output -p "TestMessage-1"
    assert_output -p "$LOG_STREAM_NAME_1"

    refute_output -p "$LOG_STREAM_NAME_2"
    refute_output -p "TestMessage-2"

    run awsinfo logs  -e now -s -10minutes InfoTestLogGroup
    assert_success
    assert_output -p "TestMessage-1"
    assert_output -p "$LOG_STREAM_NAME_1"
}

teardown(){
    remove_stack
}