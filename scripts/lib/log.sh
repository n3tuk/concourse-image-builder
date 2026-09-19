#!/usr/bin/env bash
# vim:set ft=bash:

blue=""
green=""
yellow=""
red=""
white=""
reset=""

if command -v tput >/dev/null 2>&1 && [[ -t 2 ]] && [[ -n ${TERM:-} && ${TERM} != "dumb" ]] && [[ -z ${NO_COLOR:-} ]]; then
  blue=$(tput setaf 4 2>/dev/null || true)
  green=$(tput setaf 2 2>/dev/null || true)
  yellow=$(tput setaf 3 2>/dev/null || true)
  red=$(tput setaf 1 2>/dev/null || true)
  white=$(tput bold setaf 7 2>/dev/null || true)
  reset=$(tput sgr0 2>/dev/null || true)
fi

function log:fmt() {
  local level="${1}" msgid msg
  shift

  if [[ -z ${level} ]]; then
    log:fatal "Missing required log level"
  elif [[ ${level} == "debug" ]]; then
    case "${DEBUG:-}" in
      1 | true | TRUE | yes | YES | on | ON) : ;;
      *) return 0 ;;
    esac
  fi

  declare -a arguments=("--sd-param" "level=\"${level}\"")
  declare -a parameters=()

  local time_color="${green}"
  local level_color="${reset}"
  local key_color="${blue}"
  local msg_color="${white}"
  case "${level}" in
    debug)
      time_color="${reset}"
      key_color="${reset}"
      msg_color="${reset}"
      ;;
    info) level_color="${white}" ;;
    warning) level_color="${yellow}" ;;
    err | crit) level_color="${red}" ;;
  esac

  printf "${key_color}time${reset}=${time_color}%s${reset} ${key_color}level${reset}=${level_color}%s${reset}" \
    "$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ")" "${level}" >&2

  for parameter in "${@}"; do
    test -z "${parameter}" && continue

    if [[ ${parameter} != *=* ]]; then
      msg="${parameter}"
      continue
    fi

    local key="${parameter%%=*}"
    local value="${parameter#*=}"

    arguments+=("--sd-param" "${key}=\"${value}\"")

    if [[ ${value} =~ [[:space:]] ]]; then
      parameters+=("${key_color}${key}${reset}=\"${msg_color}${value}${reset}\"")
    else
      parameters+=("${key_color}${key}${reset}=${msg_color}${value}${reset}")
    fi
  done

  if [[ -n ${msg:-} ]]; then
    if [[ ${msg} =~ [[:space:]] ]]; then
      printf " ${key_color}msg${reset}=\"${msg_color}%s${reset}\"" "${msg}" >&2
    else
      printf " ${key_color}msg${reset}=${msg_color}%s${reset}" "${msg}" >&2
    fi
  fi

  printf ' %s' "${parameters[@]}" >&2
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
