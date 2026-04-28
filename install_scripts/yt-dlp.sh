#!/usr/bin/env bash

# https://github.com/yt-dlp/yt-dlp
# https://github.com/yt-dlp/yt-dlp-wiki

set -Eeuo pipefail

source "$MYSCRIPTS/tools/utils.sh"

echo
read -r -p "Install yt-dlp? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
  check_dependencies apt curl deno ffmpeg ffprobe
  sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
  sudo chmod a+rx /usr/local/bin/yt-dlp  # Make executable
fi
