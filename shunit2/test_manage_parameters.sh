#!/usr/bin/env

under_test='./manage_parameters.sh'

setUp() { . "$under_test" ; }

aws() { : ; }

test_list_parameters() {
  main -l
  assertEquals "aws ssm describe-parameters --query \
Parameters[].[Name,Description]" "${cmd[*]}"
}

test_get_secret() {
  main -g 'foo'
  assertEquals "aws ssm get-parameters \
--name foo --with-decryption --query Parameters[].Value" "${cmd[*]}"
}

test_create_secret() {
  main -c 'foo' -s 'xxx'
  assertEquals "aws ssm put-parameter \
--name foo --value xxx --type String" "${cmd[*]}"
}

test_create_secret_with_tier() {
  main -c 'foo' -s 'xxx' -t 'Advanced'
  assertEquals "aws ssm put-parameter \
--name foo --value xxx --type String --tier Advanced" "${cmd[*]}"
}

test_delete_secret_name_only() {
  main -d 'foo'
  assertEquals "aws ssm \
delete-parameters --name foo" "${cmd[*]}"
}

. shunit2
