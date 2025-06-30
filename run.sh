#!/bin/bash

# === Defaults ===
USERNAME="embedded"
INPUT_PATH="projects"

# === Parse flags ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user)
      USERNAME="$2"
      shift 2
      ;;
    --user=*)
      USERNAME="${1#*=}"
      shift
      ;;
    -p|--path)
      INPUT_PATH="$2"
      shift 2
      ;;
    --path=*)
      INPUT_PATH="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage:"
      echo "  ./run.sh [-u|--user USER] [-p|--path PATH]"
      echo
      echo "Defaults:"
      echo "  USERNAME = $USERNAME"
      echo "  PATH     = ./$INPUT_PATH"
      exit 1
      ;;
  esac
done

# === Resolve full absolute path first ===
HOST_PROJECT_PATH="$(realpath "$INPUT_PATH")"

# === Extract just folder name ===
PROJECT_FOLDER_NAME="$(basename "$HOST_PROJECT_PATH")"

# === Final path inside Docker container ===
DOCKER_PROJECT_PATH="/home/$USERNAME/$PROJECT_FOLDER_NAME"

# === Ensure host path exists ===
mkdir -p "$HOST_PROJECT_PATH"

# === Run Docker with full access ===
docker run -it --rm \
  --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  --network host \
  -v "$HOST_PROJECT_PATH:$DOCKER_PROJECT_PATH" \
  -e LOCAL_USER_ID=$(id -u) \
  stm32-compiler /bin/bash
