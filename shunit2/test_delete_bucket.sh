#!/usr/bin/env

. shunit2/_shared.sh

under_test='./delete_bucket.sh'

setUp() { . "$under_test" ; }

tearDown() { unset OPTIND ; }

aws() {
  echo "aws $*" >> commands_log
}

python3() {
  echo "aws $*" >> commands_log
}

tearDown() {
  rm -f expected_log commands_log
}

test_simplest() {
  main "test_bucket"

  cat > expected_log <<'EOF'
aws s3 rb s3://test_bucket --force
EOF

  assertDiffEquals expected_log commands_log
}

test_versions() {
  main -v "test_bucket"

  cat > expected_log <<'EOF'
aws -c import sys, boto3
s3 = boto3.resource('s3')
bucket = s3.Bucket(sys.argv[1])
bucket.object_versions.all().delete() test_bucket
aws s3 rb s3://test_bucket --force
EOF

  assertDiffEquals expected_log commands_log
}

test_data() {
  main -v -d "test_bucket"

  cat > expected_log <<'EOF'
aws s3 rm s3://test_bucket --recursive
aws -c import sys, boto3
s3 = boto3.resource('s3')
bucket = s3.Bucket(sys.argv[1])
bucket.object_versions.all().delete() test_bucket
aws s3 rb s3://test_bucket --force
EOF

  assertDiffEquals expected_log commands_log
}

. shunit2
