##############################################################################################################
# Create the base container
##############################################################################################################
FROM nater540/alpine-unit-ruby AS base
LABEL maintainer="Nate Strandberg <nater540@gmail.com>"

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH

RUN mkdir -p "${GEM_HOME}" "${BUNDLE_BIN}" && chmod 777 "${GEM_HOME}" "${BUNDLE_BIN}"

# Destination directory for the application
ENV INSTALL_PATH /app/current

WORKDIR $INSTALL_PATH

# Reset the destination since CMake gets really confused by whats declared inside `alpine-unit-ruby`
ENV DESTDIR ""

COPY ./scripts /scripts

RUN apk --no-cache add bash && \
  /scripts/base_packages.sh

##############################################################################################################
# Compile libgraphqlparser inside it's own container
##############################################################################################################
FROM base AS libgraphqlparser
RUN /scripts/graphql_parser.sh

##############################################################################################################
# Create the final container image from the original base container
##############################################################################################################
FROM base AS final-destination

COPY --from=libgraphqlparser /usr/local/include/graphqlparser /usr/local/include/graphqlparser
COPY --from=libgraphqlparser /usr/local/lib/libgraphqlparser.so /usr/local/lib/libgraphqlparser.so
