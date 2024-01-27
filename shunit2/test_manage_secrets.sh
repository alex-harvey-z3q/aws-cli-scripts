#!/usr/bin/env

under_test='./manage_secrets.sh'

setUp() { . "$under_test" ; }

aws() { : ; }

test_list_secrets() {
  main -l
  assertEquals "aws secretsmanager list-secrets --query \
SecretList[].[Name,Description]" "${cmd[*]}"
}

test_list_secrets_arn() {
  main -l --arn
  assertEquals "aws secretsmanager list-secrets --query \
SecretList[].[Name,ARN,Description]" "${cmd[*]}"
}

test_get_secret() {
  main -g 'foo'
  assertEquals "aws secretsmanager get-secret-value \
--secret-id foo --query SecretString --output text" "${cmd[*]}"
}

test_get_secret_unwanted_desc_passed() {
  (main -g 'foo' -D 'my desc') | grep -qi usage
  assertTrue "$?"
}

test_get_secret_unwanted_secret_passed() {
  (main -g 'foo' -s 'xxx') | grep -qi usage
  assertTrue "$?"
}

test_create_secret_name_only() {
  (main -c 'foo') | grep -qi usage
  assertTrue "$?"
}

test_create_with_desc() {
  (main -c 'foo' -D 'my desc') | grep -qi usage
  assertTrue "$?"
}

test_create_and_secret() {
  main -c 'foo' -s 'xxx'
  assertEquals "aws secretsmanager create-secret \
--name foo --secret-string xxx" "${cmd[*]}"
}

test_create_with_desc_and_secret() {
  main -c 'foo' -D 'my desc' -s 'xxx'
  assertEquals "aws secretsmanager create-secret \
--name foo --description my desc --secret-string xxx" "${cmd[*]}"
}

test_rotate_secret() {
  main -r 'foo'
  assertEquals "aws secretsmanager \
rotate-secret --secret-id foo" "${cmd[*]}"
}

test_delete_secret_name_only() {
  main -d 'foo'
  assertEquals "aws secretsmanager \
delete-secret --secret-id foo" "${cmd[*]}"
}

test_update_secret_name_and_secret() {
  main -u 'foo' -s 'xxx'
  assertEquals "aws secretsmanager update-secret --secret-id foo \
--secret-string xxx" "${cmd[*]}"
}

. shunit2
