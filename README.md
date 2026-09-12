# concourse-image-builder (Concourse CI Images)

The `concourse-image-builder` repository contains the container images used by the `aur-pipelines` Concourse CI pipeline
generator. These images are used to build and run different stages of the pipeline, including building AUR packages,
signing them, uploading them to a Cloudflare R2 bucket, and cleaning up old packages from the repository.

## Local development

The repository uses [Task](https://taskfile.dev/) to build and validate the images. Install Podman, Hadolint, the Snyk
CLI, and Task before running the development workflow. The `task` command will check that the applications is requires
are installed before calling them, and will fail if any are missing.

Authenticate the Snyk CLI with `snyk auth`, or provide a token through the `SNYK_TOKEN` environment variable. The local
development tooling uses `podman` for the building and management of the container images. If you are using the rootless
configuration in Podman, you will need to enable the socket service and point the `DOCKER_HOST` environment variable at
it so that Snyk can communicate with Podman:


On Linux
with rootless Podman, start its Docker-compatible API socket and point Snyk at it before scanning:

```sh
$ systemctl --user start podman.socket

# Bash
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
# Fish
set -Ux DOCKER_HOST "unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
```

Run `task develop` to lint, build, and scan all container images.  Also run `task snyk` to perform a static analysis of
any container images built. The Snyk scan uses each image's local `:testing` tag and fails when Snyk finds a
vulnerability; scan results depend on the current Snyk vulnerability database and the packages available from the
image's base repositories.

## GitHub Actions

The GitHub Actions workflow has three stages:

1. It discovers every directory below `containers/` that contains a `Dockerfile` and creates the build matrix.
2. It runs `task lint` and `task analyse` with the repository's pinned tool versions.
3. It builds each matrix entry for `linux/amd64`, monitors and tests the image with Snyk, and publishes it when the
   workflow runs on `main`.

Pull requests run discovery, quality checks, and image builds without publishing. Snyk runs when `SNYK_TOKEN` is
available; fork pull requests cannot receive repository secrets and therefore skip the Snyk steps. Builds on `main`
require `SNYK_TOKEN` and publish images to GHCR with both `sha-<full-commit-sha>` and `latest` tags. Use the immutable
`sha-<full-commit-sha>` tag when referring to an image from Concourse.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on setting up the development environment, running tests,
linting, and submitting pull requests.

## Authors

- Jonathan Wright (<jon@than.io>)

## Licence

[MIT](LICENSE)
