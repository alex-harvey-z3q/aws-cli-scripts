#!/usr/bin/env bash

# A script to clean out SGs in an SG that cannot be deleted due to dependent objects.

groups_temp=/tmp/"$(basename "$0")"."$$"

usage() {
  echo "Usage: $0 [-h] SG_ID"
  exit 1
}

get_opts() {
  [[ -z "$1" ]] && usage
  [[ "$1" = "-h" ]] && usage
  group_id="$1"
}

_length() {
  local key="$1"
  jq --arg k "$key" '.SecurityGroups[0][$k] | length' "$groups_temp"
}

_ip_perm() {
  local index="$1"
  local key="$2"
  jq -c --arg i "$index" --arg k "$key" '.SecurityGroups[0][$k][$i | tonumber]' "$groups_temp"
}

_revoke_security_group_gress() {
  (set -x ; aws ec2 revoke-security-group-"$2" \
    --group-id "$1" --ip-permissions "$3")
}

describe_security_groups() {
  local group_id="$1"
  aws ec2 describe-security-groups \
    --group-id "$group_id"
}

revoke_ip_permissions() {
  local group_id gress key len index ip_perm

  group_id="$1"
  gress="$2"

  case "$gress" in
    ingress) key="IpPermissions"       ;;
    egress)  key="IpPermissionsEgress" ;;
  esac

  len="$(_length "$key")"
  [[ $len -eq 0 ]] && return

  for index in $(seq 0 "$((len-1))") ; do
    ip_perm="$(_ip_perm "$index" "$key")"
    _revoke_security_group_gress "$group_id" "$gress" "$ip_perm"
  done
}

_referencing_groups() {
  local group_id="$1"
  aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId, IpPermissions[*].[UserIdGroupPairs[?GroupId==`'"$group_id"'`]]]' --output text | grep -v None | cut -f 1
}

_revoke_referencing_rule() {
  local len gress

  referencing_group_id="$1"
  gress="$2"

  case "$gress" in
    ingress) key="IpPermissions"       ;;
    egress)  key="IpPermissionsEgress" ;;
  esac

  len="$(_length "$key")"
  [[ $len -eq 0 ]] && return

  for index in $(seq 0 "$((len-1))") ; do
    ip_perm="$(_ip_perm "$index" "IpPermissions")"
    if echo "$ip_perm" | jq -e --arg target_group_id "$group_id" '.UserIdGroupPairs[] | select(.GroupId==$target_group_id)' > /dev/null ; then
      _revoke_security_group_gress "$referencing_group_id" "ingress" "$ip_perm"
    fi
  done

}

revoke_referencing_rules() {
  local referencing_groups referencing_group_id len ip_perm index

  read -ra referencing_groups <<< "$(_referencing_groups "$group_id")"

  for referencing_group_id in "${referencing_groups[@]}" ; do
    describe_security_groups "$referencing_group_id" > "$groups_temp"
    _revoke_referencing_rule "$referencing_group_id" "ingress"
    _revoke_referencing_rule "$referencing_group_id" "egress"
  done
}

main() {
  get_opts "$@"
  describe_security_groups "$group_id" > "$groups_temp"
  revoke_ip_permissions "$group_id" "ingress"
  revoke_ip_permissions "$group_id" "egress"
  revoke_referencing_rules "$group_id"
  rm -f "$groups_temp"
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi
