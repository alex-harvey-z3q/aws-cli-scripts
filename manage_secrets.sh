#!/usr/bin/env bash

# This is a shell script wrapper for AWS Secrets Manager, exposing commonly-needed options in an easy-to-use interface.

export AWS_DEFAULT_OUTPUT="text"

usage() {
  echo "Usage: $0 [-h] [-l]
Usage: $0 -g SECRET_NAME
Usage: $0 -c SECRET_NAME -D SECRET_DESC -s SECRET
Usage: $0 -r SECRET_NAME
Usage: $0 -u SECRET_NAME -s SECRET
Usage: $0 -d SECRET_NAME
Lists (-l), creates (-c), updates (-u), rotates (-r), or deletes (-d) a secret."
  exit 1
}

get_opts() {
  command=(aws secretsmanager)

  while getopts "hD:s:lg:c:r:u:d:" opt ; do
    case $opt in
      h) usage ;;
      D) secret_desc="$OPTARG" ;;
      s) secret="$OPTARG" ;;
      l) command+=(list-secrets     --query      'SecretList[].[Name,Description]') ;;
      g) command+=(get-secret-value --secret-id  "$OPTARG") ;;
      c) command+=(create-secret    --name       "$OPTARG") ;;
      r) command+=(rotate-secret    --secret-id  "$OPTARG") ;;
      u) command+=(update-secret    --secret-id  "$OPTARG") ;;
      d) command+=(delete-secret    --secret-id  "$OPTARG") ;;
      \?) echo "ERROR: Invalid option -$OPTARG"
        usage ;;
    esac
  done
  shift $((OPTIND-1))
}

post_process_opts() {
  [ "${#command[@]}" -eq 2 ] && usage

  grep -q "list-secrets" <<< "${command[@]}" && return

  if grep -q "get-secret-value" <<< "${command[@]}" ; then
    [ -n "$secret" ] && usage
    [ -n "$secret_desc" ] && usage
    command+=(--query 'SecretString' --output 'text')
  fi

  if grep -q "create-secret" <<< "${command[@]}" ; then
    [ -z "$secret" ] && usage
    [ -n "$secret_desc" ] && command+=(--description "$secret_desc")
    command+=(--secret-string "$secret")
  fi

  if grep -q "update-secret" <<< "${command[@]}" ; then
    [ -z "$secret" ] && usage
    command+=(--secret-string "$secret")
  fi
}

manage_secret() { "${command[@]}" ; }

main() {
  get_opts "$@"
  post_process_opts
  manage_secret
}

if [ "$0" == "${BASH_SOURCE[0]}" ] ; then
  main "$@"
fi
