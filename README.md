# Apache Jena Fuseki
Apache Jena Fuseki docker image and helm chart for deployment to the Kubernetis cluster.

## Usage
Prerequisites:
- [Docker](https://docs.docker.com/get-docker/)
- [Helm](https://helm.sh/en/docs/)

Steps:

1. Add a repository
```bash
helm repo add jena-fuseki-repo https://glaciation-heu.github.io/jena-fuseki/helm-charts/
helm repo update
helm search repo jena-fuseki
```

2. Install a Deployment
```bash
helm install jena-fuseki jena-fuseki-repo/jena-fuseki
```

You can add extra attributes. For example:
```bash
helm install jena-fuseki jena-fuseki-repo/jena-fuseki --set deployment.replicaCount=3
```

You can install it as a DaemonSet
```bash
helm install jena-fuseki jena-fuseki-repo/jena-fuseki --set deployment.enabled=false --set daemonset.enabled=true
```

3. Delete a Deployment/DaemonSet
```bash
helm delete jena-fuseki
```

## Development
Prerequisites:
- [Docker](https://docs.docker.com/get-docker/)
- [Helm](https://helm.sh/en/docs/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)

Steps:

1. Start Minikube:
```bash
minikube start
```

2. Build a docker image
```bash
cd docker
docker build -t my-jena-fuseki:latest .
```

3. Run the docker image
```bash
docker run -p 3030:3030 my-jena-fuseki:latest
```
The Apache Jena Fuseki should then be available at http://localhost:3030/. Login and password for web interface will be in logs. More information [here](/docker/README.md).

4. Upload the docker image to minikube:
```bash
minikube image load my-jena-fuseki:latest
```

5. Install Helm Chart from source files
```bash
cd ..  # Go to the project root
helm upgrade --install my-jena-fuseki ./charts/jena-fuseki --set image.repository=my-jena-fuseki --set image.tag=latest
```

6. Delete a Deployment/DaemonSet 
```bash
helm delete my-jena-fuseki
```

## Release
To create a release, add a tag in GIT with the format a.a.a, where 'a' is an integer.
```bash
git tag 0.1.0
git push origin 0.1.0
```
The release version for branches, pull requests, and other tags will be generated based on the last tag of the form a.a.a.

## Helm Chart Versioning
The Helm chart version changed automatically when a new release is created. The version of the Helm chart is equal to the version of the release.

## GitHub Actions
[GitHub Actions](https://docs.github.com/en/actions) triggers testing and builds for each release.  

**Initial setup**  
Create the branch [gh-pages](https://pages.github.com/) and use it as a GitHub page.  

**After execution**    
- The index.yaml file containing the list of Helm Charts will be available at `https://glaciation-heu.github.io/jena-fuseki/helm-charts/index.yaml`.
- The Docker image will be available at `https://github.com/glaciation-heu/jena-fuseki/pkgs/container/jena-fuseki`.

## Collaboration guidelines
HIRO uses and requires from its partners [GitFlow with Forks](https://hirodevops.notion.site/GitFlow-with-Forks-3b737784e4fc40eaa007f04aed49bb2e?pvs=4)

## License
Different licenses apply to files added by different directories:
* /docker: [Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)
* Other directories: [MIT](https://choosealicense.com/licenses/mit/)
