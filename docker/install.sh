#!/bin/bash -Eeu

# elm-test is the runner: it finds the test modules, generates a project that
# imports them, and asks the elm compiler from the base image to build it. It
# finds that compiler on the PATH, so nothing here has to point it at one.
#
# No version is named, so a rebuild picks up the current release, and
# /versions.json records which one it was. The pairing matters
# more than usual here: a runner expects a particular compiler version and says
# so, rather than compiling anything older or newer.
npm install --global elm-test
