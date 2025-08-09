# Docker-Compose MDB
This is how we deploy the services composing the MDB in various environments.



## Installation

Assuming a Rocky Linux 9 host with docker installed.


Here should follow instructions on how to setup on a fresh machine.
Probably something along the lines of:

```shell script
curl -sL https://raw.githubusercontent.com/Bnei-Baruch/mdb-docker/main/host/install.sh | bash -s 

cd mdb-docker
vi .env

host/post-install.sh
```
