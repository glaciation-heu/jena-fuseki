#   Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Changes made by Vladimir Gladkii (HIRO-MicroDataCenters) on 11/07/2024:
#   - Removed MAINTAINER as DEPRECATED.
#   - Chnaged version and sha512 from 4.x.x to 5.0.0.
#   - Added args fuseki_sha512 and fuseki_version.
#   - Removed test the install by testing it's ping resource.
#   - Removed the group and user "fuseki".
#
#   Changes made by Péter Forgács (Lakeside Labs) on 13/02/2025-17/02/2025:
#   - Changed version and sha512 from 5.0.0 to 5.3.0.
#   - Changed Java version from 17 to 21
#   - Added dataset "slice" initialization by default.
#   - Modified the syntax for ENV and LABEL.
#   - Resolved authentication issues.


FROM eclipse-temurin:21-jre-alpine

ENV LANG=C.UTF-8
RUN set -eux; \
    apk -U upgrade; \
    apk add bash curl ca-certificates findutils coreutils gettext pwgen procps tini; \
    rm -rf /var/cache/apk/*


ARG fuseki_sha512=5204eefefb921ec029346139f5cb768fe298c816c8642ab590c9bdcee4f24cfacfb15c4266f7acf020d0d5232eea909e4af876f1d5162231ea4b8f8fe0feb3cf
ARG fuseki_version=5.3.0

ENV FUSEKI_SHA512=$fuseki_sha512
ENV FUSEKI_VERSION=$fuseki_version
ENV ASF_MIRROR=https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=
ENV ASF_ARCHIVE=https://archive.apache.org/dist/

LABEL org.opencontainers.image.url=https://github.com/glaciation-heu/jena-fuseki/tree/master/docker
LABEL org.opencontainers.image.source=https://github.com/glaciation-heu/jena-fuseki/
LABEL org.opencontainers.image.documentation=https://jena.apache.org/documentation/fuseki2/
LABEL org.opencontainers.image.title="Apache Jena Fuseki"
LABEL org.opencontainers.image.description="Fuseki is a SPARQL 1.1 server with a web interface, backed by the Apache Jena TDB RDF triple store."
LABEL org.opencontainers.image.version=${FUSEKI_VERSION}
LABEL org.opencontainers.image.licenses="(Apache-2.0 AND (GPL-2.0 WITH Classpath-exception-2.0) AND GPL-3.0)"
LABEL org.opencontainers.image.authors="Apache Jena Fuseki by https://jena.apache.org/; this image by https://orcid.org/0000-0001-9842-9718"

# Config and data
ENV FUSEKI_BASE=/fuseki

# Installation folder
ENV FUSEKI_HOME=/jena-fuseki

WORKDIR /tmp
RUN echo "$FUSEKI_SHA512  fuseki.tar.gz" > fuseki.tar.gz.sha512; \
    (\
        curl --location --silent --show-error --fail --retry-connrefused --retry 3 --output fuseki.tar.gz ${ASF_MIRROR}jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz || \
        curl --fail --silent --show-error --retry-connrefused --retry 3 --output fuseki.tar.gz $ASF_ARCHIVE/jena/binaries/apache-jena-fuseki-$FUSEKI_VERSION.tar.gz \
    ) && \
    sha512sum -c fuseki.tar.gz.sha512 && \
    tar zxf fuseki.tar.gz && \
    mv apache-jena-fuseki* $FUSEKI_HOME && \
    rm fuseki.tar.gz* && \
    cd $FUSEKI_HOME && rm -rf fuseki.war && chmod 755 fuseki-server
COPY shiro.ini $FUSEKI_HOME/shiro.ini

# Make sure to have a dataset named "slice"
COPY slice.ttl /tmp/slice.ttl

WORKDIR $FUSEKI_HOME
VOLUME $FUSEKI_BASE
EXPOSE 3030

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
