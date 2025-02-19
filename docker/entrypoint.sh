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

# Function to start Fuseki
start_fuseki() {
    echo "Starting Jena Fuseki..."
    /sbin/tini -- /jena-fuseki/fuseki-server &
    FUSEKI_PID=$!
}

# Start Fuseki for the first time
start_fuseki

# Periodically restart Fuseki
while true; do
    sleep 2100  # Restart every 35 minutes (adjust as needed)
    
    echo "Stopping Jena Fuseki..."
    kill $FUSEKI_PID
    wait $FUSEKI_PID  # Ensure the process has fully stopped
    
    echo "Restarting Jena Fuseki..."
    start_fuseki
done
