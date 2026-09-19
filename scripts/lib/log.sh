#!/usr/bin/env bash
# vim:set ft=bash:

function log:fmt() {
  local level="${1}" msgid msg
  shift

  declare -a arguments=("--sd-param" "level=\"${level}\"")
  declare -a parameters=()

  printf "time=%s level=%s" "$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")" "${level}" >&2

  for parameter in "${@}"; do
    test -z "${parameter}" && continue

    if [[ ${parameter} != *=* ]]; then
      msg="${parameter}"
      continue
    fi

    local key="${parameter%%=*}"
    local value="${parameter#*=}"

    arguments+=("--sd-param" "${key}=\"${value}\"")

    [[ ${value} =~ [[:space:]] ]] && value="\"${value}\""
    parameters+=("${key}=${value}")
  done

  if [[ -n ${msg:-} ]]; then
    [[ ${msg} =~ [[:space:]] ]] && msg="\"${msg}\""
    printf " msg=%s" "${msg}" >&2
  fi

  echo "${parameters[@]}" | xargs -n1 printf " %s" >&2
  echo >&2

  msgid=$(uuidgen --time-v7)
  logger --id=$$ \
    --tag "${0}" --msgid "${msgid}" \
    --priority "user.${level}" \
    --rfc5424=notq --sd-id logType@1 "${arguments[@]}" "${msg:-}"
}

function log:success() {
  local msg="${1}"
  shift
  log:fmt "info" "${msg}" type="success" "${@}"
}

function log:failure() {
  local msg="${1}"
  shift
  log:fmt "warning" "${msg}" type="failure" "${@}"
}

function log:info() {
  local msg="${1}"
  shift
  log:fmt "info" "${msg}" "${@}"
}

function log:warning() {
  local msg="${1}"
  shift
  log:fmt "warning" "${msg}" "${@}"
}

function log:error() {
  local msg="${1}"
  shift
  log:fmt "err" "${msg}" "${@}"
}

function log:debug() {
  local msg="${1}"
  shift
  log:fmt "debug" "${msg}" "${@}"
}

function log:fatal() {
  local msg="${1}"
  shift
  log:fmt "crit" "${msg}" type="fatal" "${@}" exit="true"
  exit 1
}
