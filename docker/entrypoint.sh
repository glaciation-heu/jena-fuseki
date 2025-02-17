#!/bin/sh

# Ensure shiro.ini exists
echo "Copying default shiro.ini to PVC..."
cp /jena-fuseki/shiro.ini /fuseki/shiro.ini

# Start Fuseki
exec /sbin/tini -- /jena-fuseki/fuseki-server
