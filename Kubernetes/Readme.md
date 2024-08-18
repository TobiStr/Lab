# Containerization Cheatsheet

## Docker

### Docker Compose

```yaml

```

### Create a Dockerfile

```Dockerfile
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

| Command                                            | Description                                                                                                     |
| -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `docker build .`                                   | Build an image in the current directory (Dockerfile required)                                                   |
| `docker run -p localPort:exposedPort <image-name>` | Create a **NEW** container from an image and publish <exposedPort> through <localPort> on the host machine      |
| `docker ps`                                        | See running Docker containers                                                                                   |
| `docker start <container-name>`                    | Run an already existing container (in detached mode)                                                            |
| `docker attach <container-name>`                   | Attach to the container (see logs)                                                                              |
| `docker logs <container-name>`                     | See all logs                                                                                                    |
| `docker stop <container-name>`                     | Stop a running container                                                                                        |
| `docker images`                                    | Show images                                                                                                     |
| `docker image inspect <image-name>`                | Show details of an image                                                                                        |
| `docker container inspect <container-name>`        | Show details of a container                                                                                     |
| `docker cp folder/. <container-name>:/target`      | Copy the contents of a folder into the running container                                                        |
| `docker cp  <container-name>:/target folder`       | Copy the contents of a folder in a running container into the folder on the host                                |
| `docker rm  <container-name>`                      | Remove the container                                                                                            |
| `docker volume ls`                                 | List all volumes                                                                                                |
| `docker container prune`                           | Delete all containers                                                                                           |
| `docker network create <network-name>`             | Create a docker network -> In networks you can use the containername as the host name to reach other containers |
| `docker network ls`                                | List all networks                                                                                               |

### Flags

| Command                                                       | Description                                                                                                 |
| ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `docker ps -a`                                                | See all Docker containers, including stopped ones                                                           |
| `docker build -t <image-name>:<tag> .`                        | Build an image and tag it                                                                                   |
| `docker run -d <image-name>:<tag>`                            | Run in detached mode (no blocking console)                                                                  |
| `docker run -it <image-name>:<tag>`                           | Run in interactive mode (console input enabled) (combines -i and -t)                                        |
| `docker run --rm <image-name>:<tag>`                          | Remove the container automatically after it stopped                                                         |
| `docker run -v <volume-name>:/app/example <image-name>:<tag>` | Add a persistent, managed & named volume to the container for the folder 'app/example' inside the container |
| `docker run -v "C:/myapp:/app" <image-name>:<tag>`            | Bind mount a folder of the host to the container (Enables live updates to code changes for example)         |
| `docker run --name <container-name> <image-name>`             | Run the image with a custom container name                                                                  |
| `docker run --network <network-name> <image-name>`            | Run the image inside a network                                                                              |
| `docker start -a <container-name>`                            | Run an already existing container (in attached mode)                                                        |
| `docker start -ai <container-name>`                           | Run an already existing container (in attached & interactive mode)                                          |
| `docker logs -f <container-name>`                             | See all logs & attach to the container                                                                      |

### Misc

- Connections to www work out of the box
- Connections to localhost must go to `host.docker.internal` in the code

## Kubernetes

### Kubectl Commands

|   Command | Description    |
| --------: | -------------- |
| `kubectl` | Kubernetes CLI |
