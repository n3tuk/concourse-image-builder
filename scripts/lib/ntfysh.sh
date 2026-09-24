#!/usr/bin/env bash
# vim:set ft=bash:

function ntfysh:url {
  printf '%s/teams/%s/pipelines/%s/jobs/%s/builds/%s' \
    "${ATC_EXTERNAL_URL}" \
    "${BUILD_TEAM_NAME}" \
    "${BUILD_PIPELINE_NAME}" \
    "${BUILD_JOB_NAME}" \
    "${BUILD_NAME}"
}

function ntfysh:send {
  local endpoint="${1}" sequence="${2}" priority="${3}" title="${4}" message="${5}"
  local url headers

  log:info "Sending message notification" endpoint="${endpoint}" sequence="${sequence}" priority="${priority}" title="${title}"

  url=$(ntfysh:url)
  headers=(
    --header "X-Sequence-ID: ${sequence}"
    --header "Title: ${title}"
    --header "Icon: https://assets.n3t.uk/icons/concourse-256x256.png"
    --header "Priority: ${priority}"
    --header "Click: ${url}"
    --header "Actions: view, View the Pipeline, ${url}"
    --header "Markdown: yes"
  )

  if ! curl --fail --silent --show-error \
    "${headers[@]}" \
    --data "${message}" \
    "${endpoint}"; then
    log:fatal "Failed to send message notification" endpoint="${endpoint}" sequence="${sequence}" priority="${priority}" title="${title}"
  fi
}

function ntfysh:message:cleanup:success {
  local repository

  repository=$(payload:params repository true)

  cat <<EOF | tr '\n' ' '
The cleanup of the \`${repository}\` Arch Linux Repository Database has **completed successfully**. The review has
confirmed that all packages referenced by the database exist in the bucket, and all previous versions of recently
updated packages have been successfully deleted.
EOF
}

function ntfysh:message:cleanup:failure {
  local repository

  repository=$(payload:params repository true)

  cat <<EOF | tr '\n' ' '
The cleanup of the \`${repository}\` Arch Linux Repository Database has **failed**. Either one or more packages
referenced by the database are missing from the bucket, or an error occurred while attempting to delete a previous
version of recently updated package. Please check the pipeline and review the logs for more information.
EOF
}
