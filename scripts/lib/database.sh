#!/usr/bin/env bash
# vim:set ft=bash:

function database:exists {
  local region="${1}" endpoint="${2}" bucket="${3}" prefix="${4}" repository="${5}" etag="${6:-}"

  log:debug "Checking for repository database" \
    region="${region}" \
    endpoint="${endpoint}" \
    bucket="${bucket}" \
    prefix="${prefix}" \
    repository="${repository}" \
    etag="${etag:-(none)}"

  declare -a arguments=(
    --region "${region}"
    --endpoint-url "${endpoint}"
    head-object
    --bucket "${bucket}"
    --key "${prefix}/${repository}.db.tar.gz"
  )

  if test -n "${etag}"; then
    arguments+=(--if-match "${etag}")
  fi

  aws s3api "${arguments[@]}" >/dev/null
}

function database:etag {
  local region="${1}" endpoint="${2}" bucket="${3}" prefix="${4}" repository="${5}" etag="${6:-}"
  local metadata

  log:debug "Retrieving repoistory metadata from Cloudflare" \
    region="${region}" \
    endpoint="${endpoint}" \
    bucket="${bucket}" \
    prefix="${prefix}" \
    repository="${repository}" \
    etag="${etag:-(none)}"

  declare -a arguments=(
    --region "${region}"
    --endpoint-url "${endpoint}"
    head-object
    --bucket "${bucket}"
    --key "${prefix}/${repository}.db.tar.gz"
  )

  if test -n "${etag}"; then
    arguments+=(--if-match "${etag}")
  fi

  metadata=$(aws s3api "${arguments[@]}" 2>/dev/null || echo "{}")
  modified=$(jq --raw-output '.LastModified // "none"' <<<"${metadata}")
  etag=$(jq --raw-output '.ETag // "none"' <<<"${metadata}" | tr -d '"')

  log:debug "Retrieved repository metadata" "modified=${modified}" "etag=${etag}"
  echo "${etag}"
}

function database:retrieve {
  local region="${1}" endpoint="${2}" bucket="${3}" prefix="${4}" repository="${5}"
  local object="s3://${bucket}/${prefix}/${repository}.db.tar.gz"

  log:debug "Retriving repoistory database from Cloudflare" \
    region="${region}" \
    endpoint="${endpoint}" \
    bucket="${bucket}" \
    prefix="${prefix}" \
    repository="${repository}" \
    etag="${etag:-(none)}"

  aws s3 --region "${region}" --endpoint-url "${endpoint}" cp "${object}" "${repository}.db.tar.gz" >/dev/null
}

function database:extract {
  local repository="${1}"

  log:debug "Extracting repository database" \
    repository="${repository}"

  tar xzf "${repository}.db.tar.gz"
}
