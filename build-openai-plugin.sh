#!/bin/sh
# OpenAI takes an uploaded archive, while Claude and Cursor read their folder from GitHub.
# Built from the last commit, so an unsaved edit or a system file cannot reach the upload.
set -eu

cd "$(dirname "$0")"

if [ -n "$(git status --porcelain --untracked-files=all -- plugins/openai)" ]; then
  echo "Commit the changes in plugins/openai first: the archive is built from the last commit." >&2
  exit 1
fi

mkdir -p dist
git archive --format=zip -o dist/openai-mcp-plugin.zip HEAD:plugins/openai
echo "Built dist/openai-mcp-plugin.zip from $(git rev-parse --short HEAD)"
