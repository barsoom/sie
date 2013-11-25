#!/bin/bash
set -e
source script/ci/support/env

notify_build "bundle exec rake"
