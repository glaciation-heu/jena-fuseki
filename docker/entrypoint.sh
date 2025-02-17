#!/bin/sh

# Ensure shiro.ini exists
echo "Copying default shiro.ini to PVC..."
cp /jena-fuseki/shiro.ini /fuseki/shiro.ini

# Ensure required directories exist
mkdir -p $FUSEKI_BASE/configuration
mkdir -p $FUSEKI_BASE/databases/slice

# Move dataset configuration if not already present
if [ ! -f "$FUSEKI_BASE/configuration/slice.ttl" ]; then
    echo "Moving slice.ttl to PVC..."
    mv /tmp/slice.ttl $FUSEKI_BASE/configuration/slice.ttl
else
    echo "slice.ttl already exists in PVC."
fi

# Increase Jetty's max form content size limit
export JVM_ARGS="${JVM_ARGS} -Xmx2048m -Xms2048m -Dorg.eclipse.jetty.server.Request.maxFormKeys=100000"
echo "JVM_ARGS: $JVM_ARGS"

# Start Fuseki
exec /sbin/tini -- /jena-fuseki/fuseki-server
