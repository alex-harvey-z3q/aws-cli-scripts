#!/usr/bin/env bash

# A script to be sourced to automate assume role.

usage() {
  echo "Usage: . $0 ROLE [-u]"
  return
}

validate_role() {
  if ! grep -Eq "arn:aws:iam::[0-9]+:role/.+" <<< "$role" ; then
    echo "Your role $role looks wrong"
    return 1
  fi
  
  return 0
}

get_caller_identity() {
  printf "Your new role\n"
  aws sts get-caller-identity
}

assume_role() {
  set -x

  read -r \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECURITY_TOKEN \
  <<< \
    "$(
  \
    aws sts assume-role \
      --role-arn "$role" \
      --role-session-name 'Session' | \
  \
    jq -r '
      .Credentials
      | [
          .AccessKeyId,
          .SecretAccessKey,
          .SessionToken
        ]
      | join(" ")'
    )"

  export \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECURITY_TOKEN

  set +x

  get_caller_identity
}

unassume_role() {
  printf "Resuming original role\n"

  set -x

  unset \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECURITY_TOKEN

  set +x

  get_caller_identity
}

main() {
  if [[ "$1" = "-h" ]] ; then
    usage
  elif [[ -z "$1" ]] ; then
    usage
  elif [[ "$1" = "-u" ]] ; then
    unassume_role
  else
    role="$1"
    validate_role && \
      assume_role
  fi
}

_is_sourced() {
  [[ -n "$ZSH_EVAL_CONTEXT" && "$ZSH_EVAL_CONTEXT" =~ :file$ ]] || [[ "$0" != "${BASH_SOURCE[0]}" ]]
}

if _is_sourced ; then
  main "$@"
elif [[ "$1" = "-h" ]] ; then
  usage
  exit 1
else
  echo "This script should be sourced not executed"
  usage
fi
