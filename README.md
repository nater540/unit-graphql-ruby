# Nginx Unit - Ruby GraphQL

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Introduction](#introduction)
- [Usage](#usage)
- [Nginx Unit Config](#nginx-unit-config)
- [Example Dockerfile](#example-dockerfile)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

Docker image based on [Alpine Unit Ruby](https://github.com/nater540/alpine-unit-ruby) that contains the bare minimum to create a GraphQL Server using Ruby 2.5.1.

## Usage

Add this to the top of your `Dockerfile`:

```
FROM nater540/unit-graphql-ruby:latest
```

..Or use a specific tagged version:

```
FROM nater540/unit-graphql-ruby:1.0.0
```

## Nginx Unit Config

**conf.json**
```json
{
  "settings": {
    "http": {
      "header_read_timeout": 30,
      "body_read_timeout": 30,
      "send_timeout": 30,
      "idle_timeout": 180,
      "max_body_size": 8388608
    }
  },
  "listeners": {
    "*:3000": {
      "application": "api"
    }
  },
  "applications": {
    "api": {
      "type": "ruby",
      "processes": {
        "max": 10,
        "spare": 5
      },
      "working_directory": "/app/current",
      "script": "/app/current/config.ru"
    }
  }
}
```

## Example Dockerfile

```docker
###################################################################################################
# Stage #1 - Create a container for installing gems & any necessary development packages.
# Important: Anything in this stage NOT copied into the final container will be DISCARDED!
###################################################################################################
FROM nater540/unit-graphql-ruby:latest AS build-env

# This container image is setup for production builds by default
# NOTE: This argument is overridden inside `docker-compose.yml` for development!
ARG BUNDLE_WITHOUT='development test'

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./

# Install necessary packages required for bundler to install the project dependencies
RUN apk --no-cache add \
  postgresql-dev \
  libxml2-dev \
  libxslt-dev \
  libffi-dev \
  build-base \
  ruby-dev

# Install gem dependencies and skip any groups specified via `BUNDLE_WITHOUT`
RUN bundle install --jobs 20 --without $BUNDLE_WITHOUT

###################################################################################################
# Stage #2 - Create the final container from the "pure" base image.
###################################################################################################
FROM nater540/unit-graphql-ruby:latest AS final

# Copy the installed gems from the prior stage
COPY --from=build-env $GEM_HOME $GEM_HOME

ADD . .

COPY ./conf.json /opt/unit/state

EXPOSE 3000
```
