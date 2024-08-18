# Containerization Cheatsheet

## Docker

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

// Expose Port 80
EXPOSE 80

// Command to be executed when running the container (not while creating the image)
CMD ["npm", "run"]
```

### Docker Commands

|   Command | Description                      |
| --------: | -------------------------------- |
| docker ps | See all running Docker processes |

## Kubernetes

### Kubectl Commands

| Command | Description    |
| ------: | -------------- |
| kubectl | Kubernetes CLI |
