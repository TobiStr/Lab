# Containerization Cheatsheet

## Docker

### Docker Compose

```yaml
# https://docs.docker.com/reference/compose-file/
version: "3.8" # pick latest
services:
  service-name-1: # <- This name can be used as a URL inside the app to connect to the service
    image: '<imagename-1>:<tag>'
    volumes:
        - data:/data/db # volumeName:/relative path
    container_name: myOwnName # Else it will be named by docker
    environment:
        # All options work:
        # a: b is an object -> therefore no - needed
        # - specifies a single item entry
        ENV_VAR_NAME: value
        - ENV_VAR_NAME=value
    env_file:
        - ../.env # Or use an env file
    networks:
        - myNet # Not necessary for a single network, since it is already in a network
  service-name-2:
    build: ./sub-folder # looks in subfolder for a "Dockerfile" and builds it
    # alternative
    build:
        context: ./sub-folder # this also is the reference folder for the dockerfile (in case of relative paths in the Dockerfile)
        dockerfile: Dockerfile
        args:
            dockerfile-arg-1: test
    ports:
        - 'hostPort:exposedPort'
    volumes:
        - logs:/app/logs
        - ./sub-folder:/app # Bind Mount -> hostFolder:containerFolder
        - /app/node_modules # Anonymous volume
    depends_on:
        - service-name-1
  service-name-3:
    image: '<imagename-3>:<tag>'
    stdin_open: true # Open in attached mode and be able to make some inputs
    tty: true
    depends_on:
        - service-name-2

volumes:
  logs:
  data: # necessary for named volumes
  # Bind mounts or anonymous volumes not necessary
```

### Create a Dockerfile

```Dockerfile
# https://docs.docker.com/reference/dockerfile/
// Create a docker image based on an existing base image
From <baseImage>

// Change the current work directory, where every following command is executing
WORKDIR /app

// Copy everything recursively from the current root folder (where Dockerfile is located) into the image to /app
COPY . /app

// Install required dependencies in the image
RUN npm install

// [not needed] Expose Port 80
EXPOSE 80

// [not needed] Folder that should be mapped to an anonymous volume (not persistent)
VOLUME ["/app/example"]

// Command to be executed when running the container (not while creating the image)
CMD ["npm", "run"]
```

### Docker Commands

| Command                                           | Description                                                                                                     |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `docker build .`                                  | Build an image in the current directory (Dockerfile required)                                                   |
| `docker run -p hostPort:exposedPort <image-name>` | Create a **NEW** container from an image and publish <exposedPort> through <hostPort> on the host machine       |
| `docker ps`                                       | See running Docker containers                                                                                   |
| `docker start <container-name>`                   | Run an already existing container (in detached mode)                                                            |
| `docker attach <container-name>`                  | Attach to the container (see logs)                                                                              |
| `docker logs <container-name>`                    | See all logs                                                                                                    |
| `docker stop <container-name>`                    | Stop a running container                                                                                        |
| `docker images`                                   | Show images                                                                                                     |
| `docker image inspect <image-name>`               | Show details of an image                                                                                        |
| `docker container inspect <container-name>`       | Show details of a container                                                                                     |
| `docker cp folder/. <container-name>:/target`     | Copy the contents of a folder into the running container                                                        |
| `docker cp  <container-name>:/target folder`      | Copy the contents of a folder in a running container into the folder on the host                                |
| `docker rm  <container-name>`                     | Remove the container                                                                                            |
| `docker volume ls`                                | List all volumes                                                                                                |
| `docker container prune`                          | Delete all containers                                                                                           |
| `docker network create <network-name>`            | Create a docker network -> In networks you can use the containername as the host name to reach other containers |
| `docker network ls`                               | List all networks                                                                                               |

### Flags

| Command                                                       | Description                                                                                                 |
| ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `docker ps -a`                                                | See all Docker containers, including stopped ones                                                           |
| `docker build -t <image-name>:<tag> .`                        | Build an image and tag it                                                                                   |
| `docker run -d <image-name>:<tag>`                            | Run in detached mode (no blocking console)                                                                  |
| `docker run -it <image-name>:<tag>`                           | Run in interactive mode (console input enabled) (combines -i and -t)                                        |
| `docker run --rm <image-name>:<tag>`                          | Remove the container automatically after it stopped                                                         |
| `docker run -e ENV_VAR_NAME=secret <image-name>:<tag>`        | Specify an environment variable                                                                             |
| `docker run -v <volume-name>:/app/example <image-name>:<tag>` | Add a persistent, managed & named volume to the container for the folder 'app/example' inside the container |
| `docker run -v "C:/myapp:/app" <image-name>:<tag>`            | Bind mount a folder of the host to the container (Enables live updates to code changes for example)         |
| `docker run --name <container-name> <image-name>`             | Run the image with a custom container name                                                                  |
| `docker run --network <network-name> <image-name>`            | Run the image inside a network                                                                              |
| `docker start -a <container-name>`                            | Run an already existing container (in attached mode)                                                        |
| `docker start -ai <container-name>`                           | Run an already existing container (in attached & interactive mode)                                          |
| `docker logs -f <container-name>`                             | See all logs & attach to the container                                                                      |

### Docker Compose Commands

| Command                   | Description                                                                                     |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| `docker compose up -d`    | (Run next to compose.yaml file) Compose a compose file and run everything in detached mode      |
| `docker compose up build` | Force a rebuild of referenced projects. Otherwise they would only be built on the first compose |
| `docker compose down`     | (Run next to compose.yaml file) Removes everything but volumes                                  |
| `docker compose down -v`  | Removes everything including volumes                                                            |

### Misc

- Connections to www work out of the box
- Connections to localhost must go to `host.docker.internal` in the code

## Kubernetes

### Kubernetes Configuration files

deployment.yaml (Filename is not important)

```yaml
# https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
apiVersion: apps/v1
# Possible kind values: Pod | Service | Deployment | ReplicaSet | StatefulSet | DaemonSet | Job | CronJob | ConfigMap | Secret | Ingress | Egress | PersistentVolume | Namespace | Node | Endpoint | Role | ClusterRole | RoleBinding | ClusterRoleBinding | NetworkPolicy | HorizontalPodAutoscaler | VerticalPodAutoscaler | Operator | APIService | Event | PodTemplate | PriorityClass | RuntimeClass | Lease | Endpoints | IngressClass ...
kind: Deployment
# https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/
metadata:
  name: my-deployment-name
spec:
  replicas: 1
  selector:
    # Specifies which pods should be controlled by the deployment
    matchLabels:
      <label-name>: <label-value> # same as in Pod below
  # This will always be a Pod, so kind: Pod must not be specified
  template:
    metadata:
      name: pod-name
      labels:
        <label-name>: <label-value>
    spec:
      containers:
        - name: container-name
          image: image-name:tag
```

service.yaml (Filename is not important)

```yaml
# https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/
apiVersion: v1
kind: Service
metadata:
  name: my-service-name
spec:
  # Specifies which pods should be part of this service
  selector:
    <label-name>: <label-value>
  # This will always be a Pod, so kind: Pod must not be specified
  ports:
    - protocol: "TCP"
      port: 80 # the port for the external network
      targetPort: 8080 # the port the application is listening on
    - protocol: "TCP"
      port: 443 # the port for the external network
      targetPort: 443 # the port the application is listening on
  # LoadBalancer = Loadbalances accross all pods. ClusterIP = IP only for inside cluster. NodePort = expose on the port of the workernode
  type: LoadBalancer
```

`minikube service <service-name>` to expose it also on minikube

To support multiple configurations in one file, you can separate the entries with `---`

### Kubernetes Terminology

| Entity                         | Description                                                                                                                                                                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Deployment                     | Resource configuration that manages the automated and declarative update, scaling, and rollback of containerized applications in a cluster.                                                                                                 |
| Service                        | Abstraction that defines a logical set of pods and a policy by which to access them, enabling reliable communication between microservices by providing stable network endpoints, load balancing, and service discovery within the cluster. |
| Pod                            | Smallest deployable unit that represents a single instance of a running process in the cluster, typically containing one or more tightly coupled containers.                                                                                |
| ReplicaSet                     | Ensures that a specified number of pod replicas are running at any given time, providing fault tolerance by automatically replacing failed pods.                                                                                            |
| DaemonSet                      | Ensures that a copy of a pod is running on all or specific nodes in a cluster, commonly used for background tasks like logging or monitoring.                                                                                               |
| StatefulSet                    | Manages the deployment and scaling of a set of pods with persistent identities and stable network identifiers, often used for stateful applications like databases.                                                                         |
| Job                            | Creates one or more pods that run to completion, ensuring that a specific task is completed successfully.                                                                                                                                   |
| CronJob                        | Schedules and runs jobs at specified times or intervals, similar to cron jobs in Unix/Linux.                                                                                                                                                |
| ConfigMap                      | Provides a way to inject configuration data into pods, allowing the separation of configuration from the application code.                                                                                                                  |
| Secret                         | Stores sensitive information, such as passwords, OAuth tokens, and SSH keys, which can be used by pods securely.                                                                                                                            |
| Namespace                      | Provides a mechanism to partition resources within a Kubernetes cluster, allowing multiple users or teams to share a cluster without affecting each other.                                                                                  |
| Ingress                        | Manages external access to services within a cluster, typically HTTP/HTTPS, through routing rules defined by the Ingress resource.                                                                                                          |
| Egress                         | Controls outbound traffic from pods to external networks, defining rules for egress traffic.                                                                                                                                                |
| Node                           | A worker machine in Kubernetes, which can be a physical or virtual machine, that runs pods.                                                                                                                                                 |
| PersistentVolume (PV)          | A storage resource in a cluster that provides durable storage for pods, independent of the pod lifecycle.                                                                                                                                   |
| PersistentVolumeClaim (PVC)    | A request for storage by a pod, binding to a PersistentVolume to consume storage.                                                                                                                                                           |
| ConfigMap                      | A resource to inject non-sensitive configuration data into pods, enabling the separation of configuration from application logic.                                                                                                           |
| Secret                         | A resource to securely inject sensitive data, like passwords or tokens, into pods.                                                                                                                                                          |
| Endpoint                       | A collection of IP addresses associated with a service, defining the actual network locations of service instances.                                                                                                                         |
| Volume                         | A directory accessible to containers in a pod that allows data to persist across container restarts.                                                                                                                                        |
| ServiceAccount                 | Provides an identity for processes that run in a pod, enabling them to interact with the Kubernetes API.                                                                                                                                    |
| Role                           | Grants permissions within a specific namespace, controlling access to resources.                                                                                                                                                            |
| ClusterRole                    | Grants permissions across the entire cluster, controlling access to resources.                                                                                                                                                              |
| RoleBinding                    | Associates a Role with a specific user or set of users within a namespace, defining their permissions.                                                                                                                                      |
| ClusterRoleBinding             | Associates a ClusterRole with users or groups at the cluster level, defining their permissions.                                                                                                                                             |
| NetworkPolicy                  | Specifies how pods are allowed to communicate with each other and with other network endpoints, controlling traffic flow in and out of pods.                                                                                                |
| ResourceQuota                  | Limits the amount of resources (like CPU, memory, and storage) that can be consumed by a namespace, preventing resource exhaustion in the cluster.                                                                                          |
| HorizontalPodAutoscaler (HPA)  | Automatically scales the number of pod replicas in a deployment or replica set based on observed CPU utilization or other custom metrics.                                                                                                   |
| LimitRange                     | Enforces limits on the resource usage (like CPU and memory) of containers in a namespace, ensuring that no container exceeds the defined limits.                                                                                            |
| Event                          | Records changes to resources or objects in the cluster, providing insights into what’s happening inside the cluster.                                                                                                                        |
| Binding                        | Assigns a pod to a specific node, manually defining the node on which the pod should run.                                                                                                                                                   |
| PodDisruptionBudget (PDB)      | Defines the minimum number of pods that must be available during voluntary disruptions, ensuring application availability.                                                                                                                  |
| HorizontalPodAutoscaler        | Automatically scales the number of pods in a deployment, replica set, or stateful set based on observed CPU utilization or other metrics.                                                                                                   |
| VerticalPodAutoscaler (VPA)    | Automatically adjusts the CPU and memory resource requests of pods to optimize resource usage.                                                                                                                                              |
| ReplicaSet                     | Ensures that a specified number of replicas of a pod are running at all times.                                                                                                                                                              |
| CustomResourceDefinition (CRD) | Extends the Kubernetes API by allowing users to define and manage custom resources.                                                                                                                                                         |
| ServiceMesh                    | A dedicated infrastructure layer that helps manage service-to-service communication, often providing features like load balancing, service discovery, and security.                                                                         |
| Operator                       | A method of packaging, deploying, and managing a Kubernetes application, automating the lifecycle management of the application.                                                                                                            |
| AdmissionController            | A plugin that intercepts requests to the Kubernetes API server before they are persisted, used to enforce policies and constraints.                                                                                                         |
| Helm Chart                     | A package manager for Kubernetes applications, simplifying the deployment and management of applications on Kubernetes clusters.                                                                                                            |
| API Gateway                    | A service that acts as a reverse proxy, routing requests from clients to the appropriate services, often providing features like load balancing, authentication, and rate limiting.                                                         |
| ContainerRuntime               | The software that runs containers in Kubernetes, such as Docker or containerd.                                                                                                                                                              |
| Scheduler                      | The component that assigns pods to nodes based on resource requirements, constraints, and available resources in the cluster.                                                                                                               |
| Controller                     | A control loop that watches the state of the cluster and makes or requests changes to move the current state towards the desired state.                                                                                                     |
| ReplicaController              | Ensures that the desired number of pod replicas are running at any given time, creating or deleting pods as needed.                                                                                                                         |
| Kubelet                        | The agent that runs on each node, ensuring that containers are running in pods as expected.                                                                                                                                                 |
| Kube-Proxy                     | A network proxy that runs on each node, maintaining network rules and facilitating network communication to the correct pod.                                                                                                                |

### Kubectl Commands

| Command                                                                      | Description                                                                             |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `kubectl`                                                                    | Kubernetes CLI                                                                          |
| `kubectl create deployment --image=...`                                      | Create a Deployment based on an image                                                   |
| `kubectl expose deployment <depl-name> --type=LoadBalancer --port=8080`      | Create a Service, expose it to the external network, and use a LoadBalancer among pods. |
| `kubectl scale deployment/<name> --replicas=2`                               | Scale a deployment and add replicas.                                                    |
| `kubectl set image deployment/<name> current-image-name=new-image-name`      | Replace the image in a deployment.                                                      |
| `minikube service <service-name>`                                            | (Localhost only) Expose the service in a Minikube cluster locally.                      |
| `kubectl get pods`                                                           | Get a list of all pods                                                                  |
| `kubectl get nodes`                                                          | Get a list of all nodes                                                                 |
| `kubectl get deployments`                                                    | Get a list of all deployments                                                           |
| `kubectl get services`                                                       | Get a list of all services                                                              |
| `kubectl get namespaces`                                                     | Get a list of all namespaces                                                            |
| `kubectl get events`                                                         | List all the events in the cluster                                                      |
| `kubectl get replicasets`                                                    | Get a list of all ReplicaSets                                                           |
| `kubectl rollout status deployment/<name>`                                   | Get the status of a current rollout                                                     |
| `kubectl delete pod <pod-name>`                                              | Delete a specific pod                                                                   |
| `kubectl logs <pod-name>`                                                    | View logs of a specific pod                                                             |
| `kubectl describe pod <pod-name>`                                            | Show detailed information about a specific pod                                          |
| `kubectl exec -it <pod-name> -- /bin/bash`                                   | Start a bash session in a running pod                                                   |
| `kubectl apply -f <file.yaml>`                                               | Apply changes from a configuration file                                                 |
| `kubectl delete -f <file.yaml>`                                              | Delete resources defined in a configuration file                                        |
| `kubectl edit deployment <depl-name>`                                        | Edit an existing deployment in-place                                                    |
| `kubectl port-forward pod/<pod-name> 8080:80`                                | Forward a local port (8080) to a port on a pod (80)                                     |
| `kubectl config view`                                                        | View the current Kubernetes config settings                                             |
| `kubectl top nodes`                                                          | Display resource (CPU/memory) usage of nodes                                            |
| `kubectl top pods`                                                           | Display resource (CPU/memory) usage of pods                                             |
| `kubectl describe node <node-name>`                                          | Show detailed information about a specific node                                         |
| `kubectl label pods <pod-name> <label-key>=<label-value>`                    | Add a label to a specific pod                                                           |
| `kubectl annotate pods <pod-name> <annotation-key>=<annotation-value>`       | Add an annotation to a specific pod                                                     |
| `kubectl rollout restart deployment/<name>`                                  | Restart a specific deployment                                                           |
| `kubectl describe replicaset <rs-name>`                                      | Show detailed information about a specific ReplicaSet                                   |
| `kubectl delete replicaset <rs-name>`                                        | Delete a specific ReplicaSet                                                            |
| `kubectl autoscale deployment <depl-name> --min=2 --max=10 --cpu-percent=80` | Autoscale a deployment based on CPU usage.                                              |
| `kubectl patch deployment <depl-name> -p '{"spec":...}'`                     | Patch a deployment with a specified JSON configuration                                  |
| `kubectl get configmaps`                                                     | Get a list of all ConfigMaps                                                            |
| `kubectl describe configmap <configmap-name>`                                | Show detailed information about a specific ConfigMap                                    |
| `kubectl create configmap <configmap-name> --from-literal=key=value`         | Create a ConfigMap from a literal value                                                 |
| `kubectl delete configmap <configmap-name>`                                  | Delete a specific ConfigMap                                                             |
| `kubectl get secrets`                                                        | Get a list of all Secrets                                                               |
| `kubectl describe secret <secret-name>`                                      | Show detailed information about a specific Secret                                       |
| `kubectl create secret generic <secret-name> --from-literal=key=value`       | Create a Secret from a literal value                                                    |
| `kubectl delete secret <secret-name>`                                        | Delete a specific Secret                                                                |
| `kubectl get ingresses`                                                      | Get a list of all Ingress resources                                                     |
| `kubectl describe ingress <ingress-name>`                                    | Show detailed information about a specific Ingress                                      |
| `kubectl create -f <ingress-file.yaml>`                                      | Create an Ingress resource from a file                                                  |
| `kubectl delete ingress <ingress-name>`                                      | Delete a specific Ingress resource                                                      |
| `kubectl get egresses`                                                       | Get a list of all Egress resources                                                      |
| `kubectl describe egress <egress-name>`                                      | Show detailed information about a specific Egress                                       |
| `kubectl create -f <egress-file.yaml>`                                       | Create an Egress resource from a file                                                   |
| `kubectl delete egress <egress-name>`                                        | Delete a specific Egress resource                                                       |
