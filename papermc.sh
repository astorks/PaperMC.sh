#!/bin/bash

if [ -z $PAPERMC_VERSION ]; then
    PAPERMC_VERSION="1.16.3"
fi
if [ -z $PAPERMC_JAR_NAME ]; then
    PAPERMC_JAR_NAME="paperclip.jar"
fi
if [ -z $PAPERMC_START_MEMORY ]; then
    PAPERMC_START_MEMORY="1G"
fi
if [ -z $PAPERMC_MAX_MEMORY ]; then
    PAPERMC_MAX_MEMORY="1G"
fi
if [ -z $PAPERMC_HOST ]; then
    PAPERMC_HOST="0.0.0.0"
fi
if [ -z $PAPERMC_PORT ]; then
    PAPERMC_PORT=25565
fi
if [ -z $PAPERMC_MAX_PLAYERS ]; then
    PAPERMC_MAX_PLAYERS=20
fi
if [ -z $PAPERMC_PLUGIN_DIR ]; then
    PAPERMC_PLUGIN_DIR="./plugins/"
fi
if [ -z $PAPERMC_WORLD_DIR ]; then
    PAPERMC_WORLD_DIR="./worlds/"
fi
if [ -z $PAPERMC_UPDATE_SECONDS ]; then
    PAPERMC_UPDATE_SECONDS=86400
fi

trap shutdown_message INT
function shutdown_message() {
    PAPERMC_SHUTDOWN=1
}

lastmod() {
    expr `date +%s` - `stat -c %Y $1`
}

while (( "$#" )); do
  case "$1" in
    --skip-update)
      PAPERMC_SKIP_UPDATE=1
      shift
      ;;
    --mojang-eula-agree)
      MOJANG_EULA_AGREE=1
      shift
      ;;
    --auto-restart)
      AUTO_RESTART=1
      shift
      ;;
    --version)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_VERSION=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --jar-name)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_JAR_NAME=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -ms|--start-memory)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_START_MEMORY=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -mx|--max-memory)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_MAX_MEMORY=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --max-players)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_MAX_PLAYERS=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --host)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_HOST=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    --port)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        PAPERMC_PORT=$2
        shift 2
      else
        echo "ERROR: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "ERROR: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

eval set -- "$PARAMS"

PAPERMC_DOWNLOAD_URL="https://papermc.io/api/v1/paper/${PAPERMC_VERSION}/latest/download"

if [ -z $MOJANG_EULA_AGREE ]; then
    echo "ERROR: You must agree to the mojang EULA by passing the \"--mojang-eula-agree\" flag or by setting the environment variable \"MOJANG_EULA_AGREE=1\"."
    exit 1
fi

function update_papermc() {
    if ! [ -f "$PAPERMC_JAR_NAME" ]; then
        echo "Downloading PaperMC ${PAPERMC_DOWNLOAD_URL} -> ${PAPERMC_JAR_NAME}..."
        echo "> curl -s -o ${PAPERMC_JAR_NAME} ${PAPERMC_DOWNLOAD_URL}"
        curl -s -o ${PAPERMC_JAR_NAME} ${PAPERMC_DOWNLOAD_URL}
    else
        if [ -z $PAPERMC_SKIP_UPDATE ]; then
            SEC_SINCE_UPDATE=$(lastmod ${PAPERMC_JAR_NAME})

            if [ "$SEC_SINCE_UPDATE" -gt "$PAPERMC_UPDATE_SECONDS" ]; then
                rm ${PAPERMC_JAR_NAME}
                echo "Updating PaperMC ${PAPERMC_DOWNLOAD_URL} -> ${PAPERMC_JAR_NAME}..."
                echo "> curl -s -o ${PAPERMC_JAR_NAME} ${PAPERMC_DOWNLOAD_URL}"
                curl -s -o ${PAPERMC_JAR_NAME} ${PAPERMC_DOWNLOAD_URL}
            else
                echo "Skipping PaperMC update, ${SEC_SINCE_UPDATE} !> ${PAPERMC_UPDATE_SECONDS}..."
            fi
        else
            echo "Skipping PaperMC update, skip flag..."
        fi
    fi

    if ! [ -z $PAPERMC_SHUTDOWN ]; then
        echo "ERROR: Download cancelled, cleaning up..."
        rm ${PAPERMC_JAR_NAME}
        exit 1
    fi
}

function start_papermc() {
    echo "> java -Xms${PAPERMC_START_MEMORY} -Xmx${PAPERMC_MAX_MEMORY} ${PAPERMC_JAVA_ARGS} -Dcom.mojang.eula.agree=true -jar ${PAPERMC_JAR_NAME} -p ${PAPERMC_PORT} -h ${PAPERMC_HOST} -s ${PAPERMC_MAX_PLAYERS} -P ${PAPERMC_PLUGIN_DIR} -W ${PAPERMC_WORLD_DIR} ${PAPERMC_ARGS} ${PARAMS}"
    java -Xms${PAPERMC_START_MEMORY} -Xmx${PAPERMC_MAX_MEMORY} ${PAPERMC_JAVA_ARGS} -Dcom.mojang.eula.agree=true -jar ${PAPERMC_JAR_NAME} -p ${PAPERMC_PORT} -h ${PAPERMC_HOST} -s ${PAPERMC_MAX_PLAYERS} -P ${PAPERMC_PLUGIN_DIR} -W ${PAPERMC_WORLD_DIR} ${PAPERMC_ARGS} ${PARAMS}
}

if [ -z $AUTO_RESTART ]; then
    update_papermc

    echo "Starting PaperMC Server..."
    start_papermc
else
    while [ -z $PAPERMC_SHUTDOWN ]; do 
        update_papermc

        echo "Starting PaperMC Server, Auto-Restart Enabled..."
        start_papermc
        sleep 3
    done
fi

echo "PaperMC Server Shutdown."