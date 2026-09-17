#!/usr/bin/env bash
# vim:set ft=bash:

# Show the value of each of the variables provided
function output:variables {
  for variable in "${@}"; do
    output:variable "${variable}"
  done
}

# Show the value of the variable
function output:variable {
  local value="${!1-}"
  if [[ -z ${value} ]]; then
    log:debug "variable=${1}" "empty=true"
  else
    log:debug "variable=${1}" "empty=false" "value=${value}"
  fi
}
