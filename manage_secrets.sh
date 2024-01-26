#!/usr/bin/env bash

# This is a shell script wrapper for AWS Secrets Manager, exposing commonly-needed options in an easy-to-use interface.

export AWS_DEFAULT_OUTPUT="text"
export MSYS_NO_PATHCONV=1  # Need for Git-for-Windows see https://github.com/git-for-windows/build-extra/blob/main/ReleaseNotes.md#known-issues

usage() {
  echo "Usage: $0 [-h] [-l] [--arn]
Usage: $0 -l
Usage: $0 -l --arn
Usage: $0 -g SECRET_NAME
Usage: $0 -c SECRET_NAME -D SECRET_DESC -s SECRET
Usage: $0 -c SECRET_NAME -D SECRET_DESC -s file://MYSECRET_FILE
Usage: $0 -r SECRET_NAME
Usage: $0 -u SECRET_NAME -s SECRET
Usage: $0 -d SECRET_NAME
Lists (-l), creates (-c), updates (-u), rotates (-r), or deletes (-d) a secret."
  exit 1
}

get_opts() {
  local opt OPTARG OPTIND l_query
  [[ -z "$1" ]] && usage

  cmd=(aws secretsmanager)

  l_query="SecretList[].[Name,Description]"
  if grep -q -- "--arn" "$@" ; then
    l_query="SecretList[].[Name,Arn,Description]"
  fi

  while getopts "hD:s:lg:c:r:u:d:" opt ; do
    case "$opt" in
      h) usage ;;
      D) secret_desc="$OPTARG" ;;
      s) secret="$OPTARG" ;;
      l) cmd+=(list-secrets     --query     "$l_query") ;;
      g) cmd+=(get-secret-value --secret-id  "$OPTARG") ;;
      c) cmd+=(create-secret    --name       "$OPTARG") ;;
      r) cmd+=(rotate-secret    --secret-id  "$OPTARG") ;;
      u) cmd+=(update-secret    --secret-id  "$OPTARG") ;;
      d) cmd+=(delete-secret    --secret-id  "$OPTARG") ;;
      \?) echo "ERROR: Invalid option -$OPTARG"
        usage ;;
    esac
  done

  shift "$((OPTIND-1))"
}

_in_cmd() {
  grep -wq "$1" <<< "${cmd[@]}"
}

post_process_opts() {
  _in_cmd "list-secrets" && return

  if _in_cmd "get-secret-value" ; then
    [[ -n "$secret" ]] && usage
    [[ -n "$secret_desc" ]] && usage
    cmd+=(--query "SecretString" --output "text")
  fi

  if _in_cmd "create-secret" ; then
    [[ -z "$secret" ]] && usage
    [[ -n "$secret_desc" ]] && cmd+=(--description "$secret_desc")
    cmd+=(--secret-string "$secret")
  fi

  if _in_cmd "update-secret" ; then
    [[ -z "$secret" ]] && usage
    cmd+=(--secret-string "$secret")
  fi
}

manage_secret() {
  (set -x ; "${cmd[@]}")
}

main() {
  get_opts "$@"
  post_process_opts
  manage_secret
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]] ; then
  main "$@"
fi
