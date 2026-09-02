#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <base-sha> <head-sha>" >&2
  exit 2
fi

base_sha=$1
head_sha=$2

changed_files=()
while IFS= read -r -d '' file; do
  changed_files+=("$file")
done < <(git diff --name-only -z "$base_sha" "$head_sha")

if [[ ${#changed_files[@]} -eq 0 ]]; then
  echo "Refusing an update with no changed files." >&2
  exit 1
fi

for file in "${changed_files[@]}"; do
  if [[ ! $file =~ ^8\.[2-5]/Dockerfile$ ]]; then
    echo "Refusing unexpected changed file: $file" >&2
    exit 1
  fi

  php_version=${file%%/*}
  work_dir=$(mktemp -d)
  base_file="$work_dir/base"
  head_file="$work_dir/head"
  normalized_base="$work_dir/normalized-base"
  normalized_head="$work_dir/normalized-head"
  trap 'rm -rf "$work_dir"' EXIT

  git show "$base_sha:$file" > "$base_file"
  git show "$head_sha:$file" > "$head_file"

  php_from_pattern="^FROM php:${php_version}-fpm@sha256:[0-9a-f]{64}$"
  if [[ $(grep -Ec "$php_from_pattern" "$base_file") -ne 1 ]] ||
     [[ $(grep -Ec "$php_from_pattern" "$head_file") -ne 1 ]]; then
    echo "Refusing a PHP tag change or malformed digest in $file." >&2
    exit 1
  fi

  base_digest=$(grep -E "$php_from_pattern" "$base_file")
  head_digest=$(grep -E "$php_from_pattern" "$head_file")
  if [[ $base_digest == "$head_digest" ]]; then
    echo "Refusing $file because its PHP digest did not change." >&2
    exit 1
  fi

  sed -E "s|^FROM php:${php_version}-fpm@sha256:[0-9a-f]{64}$|FROM php:${php_version}-fpm@sha256:<digest>|" \
    "$base_file" > "$normalized_base"
  sed -E "s|^FROM php:${php_version}-fpm@sha256:[0-9a-f]{64}$|FROM php:${php_version}-fpm@sha256:<digest>|" \
    "$head_file" > "$normalized_head"

  if ! cmp -s "$normalized_base" "$normalized_head"; then
    echo "Refusing non-digest changes in $file." >&2
    exit 1
  fi

  rm -rf "$work_dir"
  trap - EXIT
done

echo "Accepted PHP digest-only update in ${#changed_files[@]} Dockerfile(s)."
