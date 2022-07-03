#!/usr/bin/env bash

# A script to clean out SGs in an SG that cannot be deleted due to dependent objects.

groups_temp=/tmp/"$(basename "$0")"."$$"

usage() {
  echo "Usage: bash $0 [-h] SG_ID"
  exit 1
}

get_opts() {
  [[ -z "$1" ]] && usage
  [[ "$1" = "-h" ]] && usage
  group_id="$1"
}

_length() {
  jq '
    .SecurityGroups[0].'"$1"' | length
  ' "$groups_temp"
}

_ip_perm() {
  jq -c '
    .SecurityGroups[0].'"$2"'['"$1"']
  ' "$groups_temp"
}

_revoke_security_group_gress() {
  set -x
  aws ec2 revoke-security-group-"$2" \
    --group-id "$1" --ip-permissions "$3"
  set +x
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

main() {
  get_opts "$@"
  describe_security_groups "$group_id" > "$groups_temp"
  revoke_ip_permissions "$group_id" "ingress"
  revoke_ip_permissions "$group_id" "egress"
  rm -f "$groups_temp"
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi
