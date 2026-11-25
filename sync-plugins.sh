#!/bin/sh
# The plugins cannot share files: each directory checks one folder and refuses
# symlinks or paths that leave it. So the shared files are copied from the root.
set -eu

cd "$(dirname "$0")"

for plugin in claude openai cursor; do
  folder="plugins/$plugin"

  # Replaced as a whole, so a skill deleted at the root disappears here too.
  rm -rf "$folder/skills"
  cp -R skills "$folder/skills"

  mkdir -p "$folder/assets"
  cp assets/logo.png "$folder/assets/logo.png"
  cp LICENSE "$folder/LICENSE"

  # The Claude directory refuses a plugin that contains a macOS system file.
  find "$folder" -name .DS_Store -exec rm -f {} +
done
