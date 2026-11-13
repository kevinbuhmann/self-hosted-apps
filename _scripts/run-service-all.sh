#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <profile-name>"
  echo "Example: $0 pre-backup"
  echo "Example: $0 post-restore"
  exit 1
fi

profile="$1"

services=$(docker compose --profile "$profile" config --format json | \
  jq -r --arg profile "$profile" '.services | to_entries[] | select(.value.profiles // [] | index($profile)) | .key')

if [[ -z "$services" ]]; then
  echo "No $profile service found; skipping hook step."
  exit 0
fi

failures=()
for service in $services; do
  echo
  echo -e "\e[34mRunning $service...\e[0m"

  if docker compose run --rm "$service"; then
    echo -e "\e[32mOK: $service\e[0m"
  else
    echo -e "\e[31mFAILED: $service\e[0m" >&2
    failures+=("$service")
  fi
done

if [[ ${#failures[@]} -gt 0 ]]; then
  echo
  echo -e "\e[31mSome $profile services failed:\e[0m" >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

echo
echo -e "\e[32m$profile completed successfully in all apps.\e[0m"
