#!/usr/bin/env bash
# vim:set ft=bash:

payload=$(timeout 3s cat <&0)
if test -z "${payload}"; then
  log:fatal "Missing payload from stdin"
fi

function payload:lookup {
  local type="${1}" key="${2}" required="${3:-true}" default="${4:-}" sensitive="${5:-false}"
  value=$(jq --raw-output ".${type}.${key} // \"${default}\"" <<<"${payload}")

  if [[ ${required} == "true" && -z ${value} ]]; then
    log:fatal "Missing required ${type} value" type="${type}" key="${key}" exists="false"
  fi

  if [[ ${sensitive} != "false" ]]; then
    log:debug type="${type}" key="${key}" sensitive="true"
  else
    log:debug type="${type}" key="${key}" value="${value}"
  fi

  echo "${value}"
}

function payload:source {
  local key="${1}" required="${2:-true}" default="${3:-}" sensitive="${4:-false}"
  payload:lookup source "${key}" "${required}" "${default}" "${sensitive}"
}

function payload:params {
  local key="${1}" required="${2:-true}" default="${3:-}" sensitive="${4:-false}"
  payload:lookup params "${key}" "${required}" "${default}" "${sensitive}"
}

function payload:version {
  local key="${1}" required="${2:-true}" default="${3:-}" sensitive="${4:-false}"
  payload:lookup version "${key}" "${required}" "${default}" "${sensitive}"
}
