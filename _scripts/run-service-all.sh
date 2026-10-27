#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <service-name> [--profile <profile-name>]"
  echo "Example: $0 pre-backup --profile backup"
  echo "Example: $0 post-restore --profile restore"
  exit 1
fi

service_name="$1"
shift

profile_name=""
if [[ $# -gt 0 ]]; then
  if [[ "$1" == "--profile" ]] && [[ $# -ge 2 ]]; then
    profile_name="$2"
    shift 2
  else
    echo "Invalid arguments."
    echo "Usage: $0 <service-name> [--profile <profile-name>]"
    exit 1
  fi
fi

if [[ $# -ne 0 ]]; then
  echo "Invalid arguments."
  echo "Usage: $0 <service-name> [--profile <profile-name>]"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

shopt -s nullglob
docker_compose_files=("$ROOT_DIR"/*/docker-compose.yaml)

if [[ ${#docker_compose_files[@]} -eq 0 ]]; then
  echo "No docker-compose.yaml files found under: $ROOT_DIR"
  exit 1
fi

hook_ran=0
failures=()
for docker_compose_file in "${docker_compose_files[@]}"; do
  docker_compose_directory="$(dirname "$docker_compose_file")"

  compose_args=(--file "$docker_compose_file")
  if [[ -n "$profile_name" ]]; then
    compose_args+=(--profile "$profile_name")
  fi

  services="$(docker compose "${compose_args[@]}" config --services)"
  if grep -qx "$service_name" <<< "$services"; then
    hook_ran=1

    echo
    echo "Running $service_name for: $docker_compose_directory"

    if docker compose "${compose_args[@]}" run --rm "$service_name"; then
      echo -e "\e[32mOK: $docker_compose_directory\e[0m"
    else
      echo -e "\e[31mFAILED: $docker_compose_directory\e[0m" >&2
      failures+=("$docker_compose_directory")
    fi
  fi
done

if [[ "$hook_ran" -eq 0 ]]; then
  echo "No $service_name service found; skipping hook step."
fi

if [[ ${#failures[@]} -gt 0 ]]; then
  echo
  echo -e "\e[31mSome Docker Compose projects failed:\e[0m"
  printf ' - %s\n' "${failures[@]}"
  exit 1
fi

echo
echo -e "\e[32mService $service_name completed successfully in all Docker Compose projects.\e[0m"
