<!--
Changes made by Vladimir Gladkii (HIRO-MicroDataCenters) on 11/07/2024:
    - Added information about building the image.
    - Replaced Docker image stain/jena-fuseki with jena-fuseki.
    - Chnaged the description.
    - Chnaged the license information.
    - Removed contact information.
-->

# Jena Fuseki docker image
This is a [Docker](https://www.docker.com/) image for running
[Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/) with a
web interface.

This is an extended version of https://github.com/stain/jena-docker.

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

To specify Java settings such as the amount of memory to allocate for the
heap (default: 1200 MiB), set the `JVM_ARGS` environment with `-e`:

    docker run -p 3030:3030 -e JVM_ARGS=-Xmx2g jena-fuseki


## Data persistence

Fuseki's data is stored in the Docker volume `/fuseki` within the container.
Note that unless you use `docker restart` or one of the mechanisms below, data
is lost between each run of the jena-fuseki image.

To store the data in a named Docker volume container `fuseki-data`
(recommended), create it first as:

    docker run --name fuseki-data -v /fuseki busybox

Then start fuseki using `--volumes-from`. This allows you to later upgrade the
jena-fuseki docker image without losing the data. The command below also uses
`-d` to start the container in the background.

    docker run -d --name fuseki -p 3030:3030 --volumes-from fuseki-data jena-fuseki

If you want to store fuseki data in a specified location on the host (e.g. for
disk space or speed requirements), specify it using `-v`:

    docker run -d --name fuseki -p 3030:3030 -v /ssd/data/fuseki:/fuseki jena-fuseki

Note that the `/fuseki` volume must only be accessed from a single Fuseki
container at a time.

To check the logs for the container you gave `--name fuseki`, use:

    docker logs fuseki

To stop the named container, use:

    docker stop fuseki

.. or press Ctrl-C.

To restart a named container (it will remember the volume and port config)

    docker restart fuseki

### Using TDB 2

To use [TDB v2](https://jena.apache.org/documentation/tdb2/) you can pass the environment variable with `-e TDB=2`

     docker run -p 3030:3030 -e TDB=2 jena-fuseki

If you do so, then you need to use the appropriate `tdbloader2` for your data, see below for more details.


## Upgrading Fuseki

If you want to upgrade the Fuseki container named `fuseki` which use the data
volume `fuseki-data` as recommended above, do:

    docker pull jena-fuseki
    docker stop fuseki
    docker rm fuseki
    docker run -d --name fuseki -p 3030:3030 --volumes-from fuseki-data jena-fuseki

## Create empty datasets

You can create empty datasets at startup with:

    docker run -d --name fuseki -p 3030:3030 -e FUSEKI_DATASET_1=mydataset -e FUSEKI_DATASET_2=otherdataset jena-fuseki

This will create 2 empty datasets: mydataset and otherdataset.

## Data loading

Fuseki allows uploading of RDF datasets through the web interface and web
services, but for large datasets it is more efficient to load them directly
using the command line.

This docker image includes a shell script `load.sh` that invokes the
[tdbloader](https://jena.apache.org/documentation/tdb/commands.html)
command line tool and load datasets from the docker volume `/staging`.


For help, try:

    docker run jena-fuseki ./load.sh

You will most likely want to load from a folder on the host computer by using
`-v`, and into a data volume that you can then use with the regular fuseki.

Before data loading, you must either stop the Fuseki container, or
load the data into a brand new dataset that Fuseki doesn't know about yet.
To stop the docker container you named `fuseki`:

    docker stop fuseki

The example below assume you want to populate the Fuseki dataset 'chembl19'
from the Docker data volume `fuseki-data` (see above) by loading the two files
`cco.ttl.gz` and `void.ttl.gz` from `/home/chembl19` on the host
computer:

    docker run --volumes-from fuseki-data -v /home/chembl19:/staging \
       jena-fuseki ./load.sh chembl19 cco.ttl.gz void.ttl.gz

**Tip:** You might find it beneficial to run data loading from the data staging
directory in order to use tab-completion etc. without exposing the path on the
host. The `./load.sh` will expand patterns like `*.ttl` - you might have to
use single quotes (e.g. `'*.ttl'`) on the host to avoid them being expanded
locally.

If you don't specify any filenames to `load.sh`, all filenames directly under
`/staging` that match these GLOB patterns will be loaded:

    *.rdf *.rdf.gz *.ttl *.ttl.gz *.owl *.owl.gz *.nt *.nt.gz *.nquads *.nquads.gz

`load.sh` populates the default graph. To populate named
graphs, see the `tdbloader` section below.

**NOTE**: If you load data into a brand new `/fuseki` volume, a new random
admin password will be set before you have started Fuseki.
You can either check the output of the data loading, or later override the
password using `-e ADMIN_PASSWORD=pw123`.


### Using the `tdbloader2` for TDB2

Assume you have already the container running named `fuseki` you can execute

    docker exec -it fuseki  /bin/bash -c 'tdbloader2 --loc chembl19  /staging/{cco.ttl.gz,void.ttl.gz}'


## Recognizing the dataset in Fuseki

If you loaded into an existing dataset, Fuseki should find the data after
(re)starting with the same data volume (see [Data
persistence](#Data_persistence) above):

    docker restart fuseki

If you created a brand new dataset, then in Fuseki go to *Manage datasets*,
click **Add new dataset**, tick **Persistent** and provide the database name
exactly as provided to `load.sh`, e.g. `chembl19`.

Now go to *Dataset*, select from the dropdown menu, and try out *Info* and *Query*.

**Tip**: It is possible to load a new dataset into the volume of a
running Fuseki server, as long as you don't "create" it in Fuseki before
`load.sh` has finished.


## Loading with tdbloader

If you have more advanced requirements, like loading multiple datasets or named graphs, you can
use [tdbloader](https://jena.apache.org/documentation/tdb/commands.html) directly together with
a [TDB assembler file](https://jena.apache.org/documentation/tdb/assembler.html).

Note that Fuseki TDB datasets are sub-folders in `/fuseki/databases/`.

You will need to provide the assembler file on a mounted Docker volume together with the
data:

    docker run --volumes-from fuseki-data -v /home/data:/staging jena-fuseki \
      ./tdbloader --desc=/staging/tdb.ttl

Remember to use the Docker container's data volume paths within the assembler
file, e.g. `/staging/dataset.ttl` instead of `/home/data/dataset.ttl`.


## Customizing Fuseki configuration

If you need to modify Fuseki's configuration further, you can use the equivalent of:

    docker run --volumes-from fuseki-data -it ubuntu bash

and inspect `/fuseki` with the shell. Remember to restart fuseki afterward:

    docker restart fuseki

### Additional JARs on Fuseki classpath

If you need to add additional JARs to the classpath, but do not want to 
modify the volume `/fuseki`, then add the JARs to
`/fuseki-extra` which will be added as `/fuseki/extra` on start.

## License
[Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)

