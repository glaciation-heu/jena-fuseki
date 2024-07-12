# Jena Fuseki docker image
This is a [Docker](https://www.docker.com/) image for running
[Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/) with a
web interface.

This is an extended version of https://github.com/stain/jena-docker.  
You can find more documentation [here](https://github.com/stain/jena-docker).

## Usage
To build an image, execute:

    docker build -t jena-fuseki .

You can use args fuseki_sha512 and fuseki_version to change version of Apache Jena Fuseki. The version is 5.0.0 by default.

    docker build --build-arg fuseki_sha512=78074d87d4c022ef7e89b8394d2b14ead447a9201d52795d8c9adab0e03341cffc883abb849dab340bbecfc18654e1d126a47d8936241e8e2f036b0d66294c7d --build-arg fuseki_version=4.8.0 -t jena-fuseki:4.8.0 .

To try out this image, try:

    docker run -p 3030:3030 jena-fuseki

The Apache Jena Fuseki should then be available at http://localhost:3030/

To expose Fuseki on a different port, simply modify first part of `-p`:

    docker run -p 8080:3030 jena-fuseki


To load RDF graphs, you will need to log in as the `admin` user. To see the
automatically generated admin password, see the output from above, or
use `docker logs` with the name of your container.

Note that the password is only generated on the first run, e.g. when the
volume `/fuseki` is an empty directory.

You can override the admin-password using the form
`-e ADMIN_PASSWORD=pw123`:

    docker run -p 3030:3030 -e ADMIN_PASSWORD=pw123 jena-fuseki

## License
[Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)

