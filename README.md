# Docker: MySQL Server

This is a fork of [fideloper/docker-mysql](https://github.com/fideloper/docker-mysql) with modifications to fit my needs. I incorporated some comments into the files, environmental variables, and the usage of bootstraping SQL files. This image is also volume aware, meaning you can run the image with a volume.

```bash
# cd into the git repository
cd /path/to/repo/docker-mysql
# Add any .sql scripts to the build/setup folder
# Build a Docker image named "mysql" from this location "."
sudo docker build -t mysql .

# Run the docker container
sudo docker run --name mysql -v /mysqldata:/var/lib/mysql -e MYSQL_USER=admin -e MYSQL_PASSWORD=password -d mysql /sbin/my_init --enable-insecure-key
```

* `docker run` - Creates and runs a new Docker container based off an image.
* `--name mysql` - Names the newly run container "mysql".
* `-v /mysqldata:/var/lib/mysql' - Mounts a host directory as a data volume. Can be interchanged with using a Data Volume Container.
* `-e MYSQL_USER=admin -e MYSQL_PASS=password` - Uses environmental variables to create a MySQL user with admin privileges and remote access.
* `-d mysql` - Uses the image "mysql" to create the Docker container.
* `/sbin/my_init` - Run the init scripts used to kick off long-running processes and other bootstrapping, as per [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
* `--enable-insecure-key` - Enable a generated SSL key so you can SSH into the container, again as per [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker). Generate your own SSH key for production use.

## Data Volume Container

For best portability, it is advised to use a data volume container to persist and share data between containers. See [Creating and mounting a Data Volume Container](https://docs.docker.com/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container) on the Docker documentation.

The quickest way to launch a Data Volume Container is to run a command.

```bash
sudo docker run -d -v /var/lib/mysql --name mysql_data busybox true
# Verify that it was created and exited. (Data Volume Containers don't need to be running to use them)
sudo docker ps -a
# You should see a list of containers. Look for busybox image with a name "mysql_data"
CONTAINER ID        IMAGE                    COMMAND                CREATED             STATUS                      PORTS                         NAMES
92a411232665        busybox:latest           true                   20 seconds ago      Exited (0) 19 seconds ago                                 mysql_data
```

When you have your Data Volume Container created, you can use it with your mysql container:

```bash
sudo docker run --name mysql --volumes-from mysql_data -e MYSQL_USER=admin -e MYSQL_PASSWORD=password -d mysql /sbin/my_init --enable-insecure-key
```

## Bootstrap MySQL scripts

Under `build/setup`, you can place .sql scripts that will be executed each time a new container is created. By being able to bootstrap the database with sql scripts, you can easily stand up and tear down containers. 

## List of environmental variables
* `MYSQL_USER` - Username for the remote admin user. Default is "admin".
* `MYSQL_PASS` - Password of the user. Default is "password".