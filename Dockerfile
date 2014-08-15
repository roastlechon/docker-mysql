FROM phusion/baseimage:0.9.9

ENV HOME /root

RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

CMD ["/sbin/my_init"]

# Some Environment Variables
ENV DEBIAN_FRONTEND noninteractive

## Update
RUN apt-get update

## Set prompt for root password
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Install mysql-server
RUN apt-get install -y mysql-server

# Configure and add my.cnf
ADD build/my.cnf /etc/mysql/my.cnf

RUN mkdir /etc/service/mysql
ADD runit/mysql.sh /etc/service/mysql/run
RUN chmod +x /etc/service/mysql/run

# Copy over sql setup files to be run on initialization
ADD build/setup /root

# Add MySQL startup script
# This script checks for existance of MySQL data directories.
# If the directories do not exist, it runs mysql_install_db
# The script also checks for .sql files in /root/setup/ and executes them.
ADD etc/my_init.d/99_mysql_setup.sh /etc/my_init.d/99_mysql_setup.sh
RUN chmod +x /etc/my_init.d/99_mysql_setup.sh

EXPOSE 3306

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
