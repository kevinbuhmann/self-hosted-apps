#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <docker-compose-args>"
  echo "Example: $0 down"
  echo "Example: $0 up -d"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

shopt -s nullglob
docker_compose_files=("$ROOT_DIR"/*/docker-compose.yaml)

if [[ ${#docker_compose_files[@]} -eq 0 ]]; then
  echo "No docker-compose.yaml files found under: $ROOT_DIR"
  exit 1
fi

failures=()

for docker_compose_file in "${docker_compose_files[@]}"; do
  docker_compose_directory="$(dirname "$docker_compose_file")"

  echo ""
  echo "==> Running 'docker compose $*' for: $docker_compose_directory"

  if (docker compose --file "$docker_compose_file" "$@"); then
    echo -e "\e[32mOK: $docker_compose_directory\e[0m"
  else
    echo -e "\e[31mFAILED: $docker_compose_directory\e[0m" >&2
    failures+=("$docker_compose_directory")
  fi
done

if [[ ${#failures[@]} -gt 0 ]]; then
  echo
  echo -e "\e[31mSome Docker Compose projects failed:\e[0m" >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

echo
echo -e "\e[32mCommand completed successfully in all Docker Compose projects.\e[0m"
