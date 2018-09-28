#!/usr/bin/env bash

# Install base packages
apk --no-cache add \
  postgresql-client \
  ca-certificates \
  libstdc++ \
  libressl \
  libxml2 \
  git
