#!/usr/bin/env

. shunit2/_shared.sh

under_test='./revoke_rules.sh'

setUp() { . "$under_test" ; }

aws() {
  case "aws $*" in
    "aws ec2 describe-security-groups --group-id sg-11111111")
      cat shunit2/fixtures/groups.json
      ;;
  esac
  echo "aws $*" >> commands_log
}

tearDown() {
  rm -f expected_log commands_log
}

test_simplest() {
  main "sg-11111111" 2> /dev/null

  cat > expected_log <<'EOF'
aws ec2 describe-security-groups --group-id sg-11111111
aws ec2 revoke-security-group-egress --group-id sg-11111111 --ip-permissions {"FromPort":80,"IpProtocol":"tcp","IpRanges":[{"CidrIp":"10.140.6.112/32","Description":"foo"},{"CidrIp":"10.140.6.159/32","Description":"bar"}],"Ipv6Ranges":[],"PrefixListIds":[],"ToPort":80,"UserIdGroupPairs":[]}
aws ec2 revoke-security-group-egress --group-id sg-11111111 --ip-permissions {"FromPort":49152,"IpProtocol":"udp","IpRanges":[{"CidrIp":"10.23.99.20/32","Description":"baz"},{"CidrIp":"10.22.199.21/32","Description":"qux"}],"Ipv6Ranges":[],"PrefixListIds":[],"ToPort":65535,"UserIdGroupPairs":[]}
EOF

  assertDiffEquals expected_log commands_log
}

. shunit2
