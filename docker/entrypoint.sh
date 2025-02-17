#!/bin/sh

# Ensure shiro.ini exists
echo "Copying default shiro.ini to PVC..."
cp /jena-fuseki/shiro.ini /fuseki/shiro.ini

# Increase Jetty's max form content size limit
export JVM_ARGS="${JVM_ARGS} -Dorg.eclipse.jetty.server.Request.maxFormContentSize=10000000"

# Start Fuseki
exec /sbin/tini -- /jena-fuseki/fuseki-server
