#!/usr/bin/env bash

this_dir="$(pwd)"

this_script="$(basename "$0")"
current_dir="$(basename "$(pwd)")"

if [[ "$current_dir" != "aws-cli-scripts" ]] ; then
  echo "Run this script from the aws-cli-scripts repo"
fi

_cp() {
  (set -x ; cp -p "$1" /usr/local/bin/"$2")
}

_link() {
  (set -x ; cd /usr/local/bin && ln -sf $*)
}

if [[ "$1" == "-l" ]]; then
  function=_link
else
  function=_cp
fi

for file_name in *.sh *.awk ; do
  [[ "$file_name" == "$this_script" ]] && continue
  new_name="$(basename "$file_name")"
  "$function" "$this_dir"/"$file_name" "$new_name"
done
