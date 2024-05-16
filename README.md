# MeevsBox Paper Minecraft Server

## Table of Contents

1. [Introduction](#introduction)
2. [Docker Information](#docker_information)
    1. [Build Arguments](#build_arguments)
        1. [Java Control Arguments](#java_control_arguments)
        2. [Minecraft Control Arguments](#minecraft_control_arguments)
        3. [File System Control Arguments](#file_system_control_arguments)
    2. [Environment Variables](#environment_variables)
        1. [Java Environment Variables](#java_environment_variables)
        2. [Minecraft Environment Variables](#minecraft_environment_variables)
    3. [Exposed Ports](#exposed_ports)
    4. [Volume Locations](#volume_locations)
3. [Setting up the Server](#setting_up_the_server)
    1. [Building the Image](#building_the_image)
    2. [Configuring the Server](#configuring_the_server)
4. [Docker Compose](#docker_compose_information)
    1. [Building](#docker_compose_building)
    2. [Running](#docker_compose_running)

## Introduction <a name=introduction></a>

This documentation is provided to aid in the building of the **MeevsBox Paper Minecraft Server**. This documentation provides information on how to build the image, configure a server and run the server within a Docker container.

## Docker Information <a name=docker_information></a>

### Build Arguments <a name=build_arguments></a>

#### Java Control Arguments <a name=java_control_arguments></a>

- ``JAVA_VERSION`` -- The version of the Java runtime environment used to host the server **(default = "17")**

#### Minecraft Control Arguments <a name=minecraft_control_arguments></a>

- ``MC_VERSION`` -- The version of the Minecraft server to be used **(default = "1.20.2")**
- ``PAPER_VERSION`` -- The version of Paper used on the server **(default = "")**
*Note: Blank is interpreted as "latest", and thus the latest build for the given Minecraft version will always be used!*

#### File System Control Arguments <a name=file_system_control_arguments></a>

- ``INSTALL_DIR`` -- The directory where the server will be installed **(default = "/home/${USER}/paper_mc_server/")**

### Environment Variables <a name=environment_variables></a>

#### Java Environment Variables <a name=java_environment_variables></a>

- ``JAVA_VERSION`` -- The version of the Java runtime environment used to host the server **(default = "17")**
- ``MIN_RAM`` -- The minimum amount of RAM allocated to the JVM **(default = "1G")**
- ``MAX_RAM`` -- The maximum amount of RAM allocated to the JVM **(default = "4G")**

#### Minecraft Environment Variables <a name=minecraft_environment_variables></a>

- ``MC_VERSION`` -- The version of the Minecraft server to be used **(default = "1.20.2")**
- ``PAPER_VERSION`` -- The version of Paper used on the server **(default = "")**
- ``MC_EULA`` -- Flag to indicated agreement to the Minecraft server EULA **(default = "false")**


### Exposed Ports <a name=exposed_ports></a>

- ``25565/tcp`` -- Game port

### Volume Locations <a name=volume_locations></a>

- ``${INSTALL_DIR}`` -- The `${INSTALL_DIR}` directory contains all configuration files, mods and world data used by the server. It will be persistant by default.

## Setting up the Server <a name=setting_up_the_server></a>

### Building the Image <a name=building_the_image></a>

Building the Paper Minecraft can be done by invoking:
```bash
docker buildx build ./
```

in the directory containing this README. 
The version of the Minecraft server can be controlled through the `MC_VERSION` build argument. Similarly, the Paper version can be controlled through the `PAPER_VERSION` variable. 
For example, if you wanted to build a **1.12.2 Minecraft** server using **Paper 1620**, this command would look like:
```bash
docker buildx build --build-arg MC_VERSION=1.12.2 --build-arg PAPER_VERSION=14.23.5.2859 ./
```

*Note: this example does not give a name to the image, it is* ***highly recommended*** *to assign a tag to your image!*

A container can then be invoked from this image.

### Running the Server

Running the server can be done by invoking:
```bash
docker container run --tty --interactive --publish 25565:25565/tcp --env MC_EULA=true ${YOUR_PAPER_MC_IMAGE_TAG}
```

*Note: Without configuring the server, `MC_EULA`* ***MUST*** *be set to* ***true*** *otherwise the server will not start.*

### Configuring the Server <a name=configuring_the_server></a>

The server created in the previous chapter is a bare-bones Minecraft server.
When run in a container, it will be a default "out-of-the-box" Minecraft server with default configurations.
To configure the server, we must first create the container without actually running it.

Provided in this directory should be a file `paper_mc_config_files.tar`.
This tarball contains a default Paper Minecraft server layout and configuration files.
You may extract it to any directory you like, but preferably in a new, empty directory.
This can be done by:
```bash
mkdir ${MY_NEW_DIR} && tar --extract --file ./paper_mc_config_files.tar --directory ${MY_NEW_DIR}
```

From here, you can edit the configuration files how you desire, import your own world into the `world` directory, and install any plugins you want into the `plugins` directory.
Once you have made the modifications you want, you must import these files into the container.
But first, the container must actually be created without running it.
This can be done by invoking:

```bash
docker container create --name ${MC_SERVER_NAME} --tty --interactive --publish 25565:25565/tcp --MC_EULA=true ${PAPER_MC_IMAGE_TAG}
```

Now we can copy the files into the container by running:

```bash
docker container cp ${MY_NEW_DIR}/. ${MC_SERVER_NAME}:${INSTALL_DIR}
```

Take special note of the `INSTALL_DIR` as you must specify this as an absolute path within the container.
Once the transfer is complete, we can start our server through:
```bash
docker container start --attach --interactive ${MC_SERVER_NAME}
```

## Docker Compose Information <a name=docker_compose_information></a>
Docker compose greatly simplifies the building process!
Provided in the root directory of the projcet is a docker compose file `compose.yaml` along with a default environment variable file `.env`.
These files will build the version of minecraft specified in the `.env` file.
(This does need to be manually updated as newer Minecraft versions release, this is just the reality of things!)
Within the `versions` subdirectory, there should be an environment file contained for each version. This makes configuring the build process to build any version extremely easy!

### Building <a name=docker_compose_building></a>
To build the **latest** version (or at least the default version provided).
From the root of the project, run
```bash
docker compose create --build
```
Once again, this will use the `.env` file provided in the root directory to build the container.

To build a specific version of Minecraft, you must specify an alternative environment file to use.
This can be done using the `--env-file` flag.
For example, to build Minecraft version 1.20.2; from the root of the project, you would run
```bash
docker compose --env-file ./versions/1.20.2/1.20.2.env create --build
```
Assuming that the environment file `./versions/1.20.2/1.20.2.env` exists.

### Running <a name=docker_compose_running></a>
The container can now be started normally via vanilla docker commands
```bash
docker container start --interactive --attach paper_mc-<version>
```

