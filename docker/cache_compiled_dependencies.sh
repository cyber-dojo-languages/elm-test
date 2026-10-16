#!/bin/sh -eu
# Run once, when the image is built, from the warmup project's directory.
#
# Compiling the packages named in elm.json takes about five seconds, and
# elm-test compiles them again in a project it generates, so a kata doing this
# for itself waits about ten seconds for every test run. Elm does keep the
# result, in elm-stuff beside the project, but a kata's elm-stuff goes with the
# container it was made in. So the warmup project compiles them here and a kata
# starts from a copy.
#
# What decides whether elm re-verifies the packages is elm.json's modification
# time, not its contents: touching elm.json without changing a character of it
# costs the full five seconds again, while editing a source file costs nothing.
# So the cache is only usable by a kata whose elm.json still carries the time
# this one had, which is why the reference copy below is kept with -p and why
# cyber-dojo.sh restores the tree with -p as well. A copy that loses the
# timestamps is a cache that is never read.

readonly CACHE=/etc/elm/cache

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing. Short grep
# flags because busybox grep has no long ones.
add_test_framework()
{
  name="${1}"
  version="${2}"
  entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

# The warmup's elm.json names no test dependencies, so the newest
# elm-explorations/test that works with the rest is resolved here, along with
# whatever it needs. A kata has no network, so the start-point's elm.json has
# to name exactly what is cached, and cyber-dojo.sh uses the cache only when
# the two are identical. The resolved elm.json is written to
# /start_point_sync/, which the propagation bot copies into the start-point
# whenever this image's versions change.
#
# An application's elm.json has to name the exact compiler that builds it, and
# the base image follows the newest elm, so the version is set from the
# compiler before anything is resolved.
sed -i "s/\"elm-version\": \"[^\"]*\"/\"elm-version\": \"$(elm --version)\"/" elm.json
yes | elm-test install elm-explorations/test
mkdir -p /start_point_sync
cp elm.json /start_point_sync/elm.json

readonly TEST_VERSION=$(sed -n 's|.*"elm-explorations/test": "\(.*\)".*|\1|p' elm.json)
if [ -z "${TEST_VERSION}" ]; then
  echo 'elm.json names no elm-explorations/test' >&2
  exit 1
fi
add_test_framework elm-explorations/test "${TEST_VERSION}"
add_test_framework elm-test "$(elm-test --version)"
cat /versions.json

# Any whole second will do. It is never shown to anyone: what matters is only
# that it has no fractional part, for the reason given beside the touch below.
readonly PINNED_TIME=202001010000

# Elm stores elm.json's modification time to finer than a second and compares
# it exactly, while the tools that carry that time to a kata (cp -p here, and
# touch -r in cyber-dojo.sh) work in whole seconds. Left as it is, the time
# recorded below is one no kata can ever present, and every run pays the full
# compile while looking like it has a cache. Pinning elm.json to a whole second
# first is what makes the recorded time reproducible.
touch -t "${PINNED_TIME}" elm.json

# Compiled twice over, once the way cyber-dojo.sh type-checks the source files
# and once the way elm-test builds its generated project, because the two keep
# their results in separate places and a kata pays for both.
elm make --output=/dev/null $(find src -type f -name '*.elm')
elm-test --workers 1

# elm-test writes its generated project's own elm.json, and that one carries a
# finer-than-a-second time as well. It needs the same whole second for the same
# reason, and since elm-test leaves that file alone once it exists, pinning it
# and running elm-test once more is what gets the pinned time recorded.
find elm-stuff/generated-code -name elm.json | while read -r generated; do
  touch -t "${PINNED_TIME}" "${generated}"
done
elm-test --workers 1

mkdir -p "${CACHE}"
cp -R -p elm-stuff "${CACHE}/elm-stuff"

# The elm.json these packages were compiled from. cyber-dojo.sh compares a
# kata's elm.json against it and uses the cache only when the two are identical,
# so a learner who adds a dependency gets the packages they asked for rather
# than the ones this warmup happened to have. It also carries the modification
# time the cache was built with, which is the one a kata has to restore.
cp -p elm.json "${CACHE}/elm.json"

echo 'Cached compiled dependencies:'
ls -l "${CACHE}/elm.json"
find "${CACHE}/elm-stuff" -name '*.dat'
