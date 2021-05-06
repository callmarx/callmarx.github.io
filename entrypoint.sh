#!/bin/sh
set -e

# check/install gem dependencies with 4 parallel jobs
bundle check || bundle install -j4

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
