#!/usr/bin/env bash
# vim:set ft=bash:

payload=$(cat <&0)

function payload:source {
  local key="${1}" default="${2:-}"
  jq --raw-output ".source.${key} // \"${default}\"" <<<"${payload}"
}

function payload:param {
  local key="${1}" default="${2:-}"
  jq --raw-output ".param.${key} // \"${default}\"" <<<"${payload}"
}

function payload:version {
  local key="${1}"

  value=$(jq --raw-output ".version.${key}" <<<"${payload}")
  if [[ -z ${value} || ${value} == "null" ]]; then
    log:fatal "Missing required version identifier" version="${key}" exists="false"
  fi

  log:debug "version=${key}" "value=${value}"
  echo "${value}"
}

function payload:endpoint {
  local value
  value=$(payload:param "endpoint")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="endpoint" exists="false"
  fi

  log:debug "param=endpoint" "value=${value}"
  echo "${value}"
}

function payload:access_key_id {
  local value
  value=$(payload:param "access_key_id")
  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="access_key_id" exists="false"
  fi

  log:debug "param=access_key_id" sensitive="true"
  echo "${value}"
}

function payload:secret_access_key {
  local value
  value=$(payload:param "secret_access_key")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="secret_access_key" exists="false"
  fi

  log:debug "param=secret_access_key" sensitive="true"
  echo "${value}"
}

function payload:region {
  local value
  value=$(payload:param "region" "weur")

  log:debug "param=region" value="${value}"
  echo "${value}"
}

function payload:bucket {
  local value
  value=$(payload:param "bucket")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="bucket" exists="false"
  fi

  log:debug "param=bucket" value"=${value}"
  echo "${value}"
}

function payload:prefix {
  local value
  value=$(payload:param "prefix")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="prefix" exists="false"
  fi

  log:debug "param=prefix" value="${value}"
  echo "${value}"
}

function payload:repository {
  local value
  value=$(payload:param "repository")

  if [[ -z ${value} ]]; then
    log:fatal "Missing required parameter" param="repository" exists="false"
  fi

  log:debug "param=repository" value="${value}"
  echo "${value}"
}
