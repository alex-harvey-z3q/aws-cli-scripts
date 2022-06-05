assertDiffEquals() {
  local message="unexpected sequence of commands issued"

  if [ "$#" -eq 3 ] ; then
    local message="$1"
    shift
  fi

  local file1="$1"
  local file2="$2"

  assertEquals "unexpected sequence of commands issued" "" \
    "$(diff -wu "$file1" "$file2" 2>&1 | colordiff | DiffHighlight.pl)"
}
