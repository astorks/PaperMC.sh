# PaperMC.sh

![License](https://img.shields.io/github/license/astorks/papermc.sh?style=for-the-badge)
[![PaperMC](https://img.shields.io/badge/PaperMC-v1.16.3-blue?style=for-the-badge)]()

A single bash script to install/run a PaperMC server.<br />

## Environment Variables & Startup Arguments
| Name                      | Argument | Description | Default Value |
| ------------------------- | -------- | ------------| ------------- |
| MOJANG_EULA_AGREE         | --mojang-eula-agree | Set this environment variable to agree to the Mojang EULA | N/A |
| PAPERMC_VERSION           | --version [version] | The minecraft version to download the latest PaperMC release. | 1.18.1 |
| PAPERMC_JAR_NAME          | --jar-name [name] | The name of the PaperMC jar file. | paperclip.jar |
| PAPERMC_START_MEMORY      | --start-memory [memory] | The minimum ammount of memory to allocate to the JVM. | 1G |
| PAPERMC_MAX_MEMORY        | --max-memory [memory] | The maximum ammount of memory to allocate to the JVM. | 1G |
| PAPERMC_HOST              | --host [ip-address] | The server ip address to bind to or 0.0.0.0 to bind to all addresses. | 0.0.0.0 |
| PAPERMC_PORT              | --port [port] | The server port. | 25565 |
| PAPERMC_MAX_PLAYERS       | --max-players [player-count] | The maximum amount of players that can connect to the server at once. | 20 |
| PAPERMC_PLUGIN_DIR        | N/A | The path to the plugins folder relative to the server root. | ./plugins/ |
| PAPERMC_WORLD_DIR         | N/A | The path to the worlds folder relative to the server root. | ./worlds/ |
| PAPERMC_SKIP_UPDATE       | --skip-update | Skip PaperMC updates, will still download the latest version if jar file is missing. | N/A |
| AUTO_RESTART              | --auto-restart | Auto-Restart the server unless a Ctrl-C command is issued or the container is stopped | N/A |


## Basic Example
```bash
~$ mkdir papermc && cd papermc
~/papermc$ curl -s -o papermc.sh https://raw.githubusercontent.com/astorks/PaperMC.sh/master/papermc.sh
~/papermc$ chmod +x papermc.sh
~/papermc$ ./papermc.sh --mojang-eula-agree --version 1.16.3 --min-memory 1G --max-memory 1G
```

## Docker Example
```bash
~$ docker run -v papermc:/var/opt/papermc -p 25565:25565 -e MOJANG_EULA_AGREE=1 -e PAPERMC_VERSION=1.16.3 -e PAPERMC_MIN_MEMORY=1G -e PAPERMC_MAX_MEMORY=1G -it astorks/papermc.sh:latest
```
