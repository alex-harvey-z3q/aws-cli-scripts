#!/usr/bin/env awk

# An AWK script that can reset spacing in a CloudFormation YAML template in a visually appealing way.

BEGIN {
  sections = "^(\
Parameters|\
Conditions|\
Metadata|\
Mappings|\
Resources|\
Outputs)"
  count = 0
  threshold = 10
  two_sp = "\n"
  one_sp = ""
}

/^$/ {
  next
}

{
  ++count
}

$0 ~ sections {
  count = 0
  if (! /^Parameters/) {
    print two_sp
  } else {
    print one_sp
  }
  print ; getline ; print
  next
}

/^  [a-zA-Z]/ {
  if (count >= threshold) {
    print two_sp
  } else {
    print one_sp
  }
  count = 0
  print
  next
}

/# vim/ {
  print one_sp
  print
  next
}

{
  print
}
