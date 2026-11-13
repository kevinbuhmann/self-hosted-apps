#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <compose-args>"
  echo "Example: $0 down"
  echo "Example: $0 up -d"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mapfile -t compose_files < <(
  find "$ROOT_DIR" -mindepth 2 -maxdepth 2 -type f -name compose.yaml ! -path "$ROOT_DIR/backup-restore/*" | sort
)

if [[ ${#compose_files[@]} -eq 0 ]]; then
  echo "No compose.yaml files found under: $ROOT_DIR"
  exit 1
fi

failures=()

for compose_file in "${compose_files[@]}"; do
  compose_directory="$(dirname "$compose_file")"

  echo ""
  echo "==> Running 'docker compose $*' for: $compose_directory"

  if (docker compose --file "$compose_file" "$@"); then
    echo -e "\e[32mOK: $compose_directory\e[0m"
  else
    echo -e "\e[31mFAILED: $compose_directory\e[0m" >&2
    failures+=("$compose_directory")
  fi
done

if [[ ${#failures[@]} -gt 0 ]]; then
  echo
  echo -e "\e[31mSome projects failed:\e[0m" >&2
  printf ' - %s\n' "${failures[@]}" >&2
  exit 1
fi

echo
echo -e "\e[32mCommand completed successfully in all projects.\e[0m"
