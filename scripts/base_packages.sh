#!/usr/bin/env bash

# Install base packages
apk --no-cache add \
  postgresql-client \
  ca-certificates \
  libstdc++ \
  libressl \
  libxml2 \
  git

addgroup -g 1000 -S app && adduser -u 1000 -S app -G app
chown -R app:app "${GEM_HOME}" "${BUNDLE_BIN}" "${INSTALL_PATH}"
