#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat ${MY_DIR}/docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

# Confirms the version of one tool inside the image. docker/install.sh asks npm
# for elm-test without naming a version, so a rebuild picking up a new release
# stops here and names it, rather than changing what the image offers without
# saying so.
check_version()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r version_command="${3}"
  local -r actual=$(docker run --rm -i ${IMAGE_NAME} sh -c "${version_command}")

  if echo "${actual}" | grep -q "${expected}"; then
    echo "${name} VERSION CONFIRMED as ${expected}"
  else
    echo "${name} VERSION EXPECTED: ${expected}"
    echo "${name} VERSION   ACTUAL: ${actual}"
    exit 42
  fi
}

# The compiler is checked here as well as in the base image it comes from,
# because it is the pairing that has to hold: elm-test refuses to work with a
# compiler whose version it was not built for.
check_version elm      0.19.2   'elm --version'
check_version elm-test 0.19.2-1 'elm-test --version'

# The test framework itself, which npm neither installs nor can bump. It is
# pinned in docker/warmup/elm.json, and the start-point's own elm.json has to
# ask for this same version: it is the only one compiled into the image, and a
# kata has no network to fetch another.
check_version elm-explorations/test 2.2.1 'ls /etc/elm/home/0.19.2/packages/elm-explorations/test'
