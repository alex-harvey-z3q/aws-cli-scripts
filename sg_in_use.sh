#!/bin/bash

usage() {
  echo "Usage: $0 SG_ID"
  exit 1
}

_instances() {
  local instances="$( (set -x ; aws ec2 describe-instances --filters "Name=instance.group-id,Values=$sg_id") | jq -r .Reservations[])"
  if [[ -z "$instances" ]] ; then
    echo "DescribeInstances returned no Reservations"
  else
    echo "Found EC2 instances associated with the Security Group $sg_id."
    exit 1
  fi
  echo "$instances"
}

_interfaces() {
  local interfaces="$( (set -x ; aws ec2 describe-network-interfaces --filters "Name=group-id,Values=$sg_id") | jq -r .NetworkInterfaces[])"
  if [[ -z "$interfaces" ]] ; then
    echo "DescribeNetworkInterfaces returned no NetworkInterfaces"
  else
    echo "Found network interfaces associated with the Security Group $sg_id."
    exit 1
  fi
  echo "$interfaces"
}

_sgs() {
  local sg_references="$( (set -x ; aws ec2 describe-security-groups) | jq -r '.SecurityGroups[] | select(.IpPermissions[]? | .UserIdGroupPairs[]?.GroupId == "'$sg_id'") or select(.IpPermissionsEgress[]? | .UserIdGroupPairs[]?.GroupId == "'$sg_id'")')"
  if [[ -z "$sg_references" ]] ; then
    echo "DescribeSecurityGroups returned no references"
  else
    echo "Found references to the Security Group $sg_id in other Security Groups."
    exit 1
  fi
  echo "$sg_references"
}

_lbs() {
  local load_balancers="$( (set -x ; aws elbv2 describe-load-balancers) | jq -r '.LoadBalancers[] | select(.SecurityGroups[]? == "'$sg_id'")')"
  if [[ -z "$load_balancers" ]] ; then
    echo "DescribeLoadBalancers returned no references"
  else
    echo "Found Load Balancers associated with the Security Group $sg_id."
    exit 1
  fi
  echo "$load_balancers"
}

main() {
  [[ "$1" = "-h" ]] && usage
  [[ -z "$1" ]] && usage

  sg_id="$1"

  _instances
  _interfaces
  _sgs
  _lbs

  echo "Checks completed."
}

main "$@"
