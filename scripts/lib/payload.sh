#!/usr/bin/env bash
# vim:set ft=bash:

payload=$(timeout 3s cat <&0)
if test -z "${payload}"; then
  log:fatal "Missing payload from stdin"
fi

function payload:source {
  local key="${1}" default="${2:-}"
  jq --raw-output ".source.${key} // \"${default}\"" <<<"${payload}"
}

function payload:param {
  local key="${1}" default="${2:-}"
  jq --raw-output ".param.${key} // \"${default}\"" <<<"${payload}" 2>/dev/null
}

function payload:version {
  local key="${1}"

  value=$(jq --raw-output ".version.${key}" <<<"${payload}" 2>/dev/null)
  if [[ -z ${value} || ${value} == "null" ]]; then
    log:fatal "Missing required version identifier" version="${key}" exists="false"
  fi

  log:debug version="${key}" value="${value}"
  echo "${value}"
}

function payload:endpoint {
  local value
  value=$(payload:source "endpoint")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="endpoint" exists="false"
  fi

  log:debug source="endpoint" value="${value}"
  echo "${value}"
}

function payload:access_key_id {
  local value
  value=$(payload:source "access_key_id")
  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="access_key_id" exists="false"
  fi

  log:debug source="access_key_id" sensitive="true"
  echo "${value}"
}

function payload:secret_access_key {
  local value
  value=$(payload:source "secret_access_key")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="secret_access_key" exists="false"
  fi

  log:debug source="secret_access_key" sensitive="true"
  echo "${value}"
}

function payload:region {
  local value
  value=$(payload:source "region" "weur")

  log:debug source="region" value="${value}"
  echo "${value}"
}

function payload:bucket {
  local value
  value=$(payload:source "bucket")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="bucket" exists="false"
  fi

  log:debug source="bucket" value="${value}"
  echo "${value}"
}

function payload:prefix {
  local value
  value=$(payload:source "prefix")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="prefix" exists="false"
  fi

  log:debug "source=prefix" value="${value}"
  echo "${value}"
}

function payload:repository {
  local value
  value=$(payload:source "repository")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required source parameter" source="repository" exists="false"
  fi

  log:debug source="repository" value="${value}"
  echo "${value}"
}
