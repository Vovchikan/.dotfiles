#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import argparse
import re
import sys
import subprocess
import threading
import time
from datetime import datetime
from pathlib import Path
from typing import IO


# --- Defaults with comments explaining their impact ---
DEFAULT_EXTENSIONS: list[str] = ["mp4", "mov", "avi", "mkv", "flv", "wmv"]
DEFAULT_VIDEO_CODEC: str = "libx265"  # H.265/HEVC: better compression than H.264 at same quality
DEFAULT_SCALE: str = "1920:1080"  # Output resolution; lower = smaller file, less quality
DEFAULT_CRF: str = "24"  # Constant Rate Factor; 0=lossless, 23=default, 28=smaller, 18=visually lossless
DEFAULT_AUDIO_CODEC: str = "aac"  # Audio codec; aac is widely compatible
DEFAULT_AUDIO_BITRATE: str = "128k"  # Audio bitrate; lower = smaller file, worse sound


def parse_exclude_input(user_input: str, total_count: int) -> set[int]:
  """Parse user input like '1, 3-5, 8-10' into a set of 1-based indices to exclude."""
  excluded: set[int] = set()
  if not user_input.strip():
    return excluded
  parts: list[str] = user_input.split(",")
  for part in parts:
    part = part.strip()
    if not part:
      continue
    if "-" in part:
      try:
        start_str, end_str = part.split("-", 1)
        start = int(start_str.strip())
        end = int(end_str.strip())
        if start < 1 or end > total_count or start > end:
          print(f"  Invalid range: {part}")
          continue
        excluded.update(range(start, end + 1))
      except ValueError:
        print(f"  Invalid range format: {part}")
    else:
      try:
        num = int(part)
        if num < 1 or num > total_count:
          print(f"  Number out of range: {num}")
          continue
        excluded.add(num)
      except ValueError:
        print(f"  Invalid number: {part}")
  return excluded


def format_size(size_bytes: int) -> str:
  """Convert bytes to human-readable string."""
  if size_bytes == 0:
    return "0 B"
  units: list[str] = ["B", "KB", "MB", "GB", "TB"]
  i = 0
  size = float(size_bytes)
  while size >= 1024 and i < len(units) - 1:
    size /= 1024.0
    i += 1
  return f"{size:.2f} {units[i]}"


def format_duration(seconds: float) -> str:
  """Format seconds as HH:MM:SS."""
  hrs = int(seconds // 3600)
  mins = int((seconds % 3600) // 60)
  secs = int(seconds % 60)
  return f"{hrs:02d}:{mins:02d}:{secs:02d}"


def get_video_files(directory: Path, extensions: list[str]) -> list[Path]:
  """Find video files in directory matching given extensions."""
  files: list[Path] = []
  for ext in extensions:
    pattern = f"*.{ext.lower().lstrip('.')}"
    files.extend(directory.glob(pattern))
    files.extend(directory.glob(pattern.upper()))
  # Remove duplicates and sort
  unique: set[Path] = set(files)
  sorted_files: list[Path] = sorted(unique)
  return [f for f in sorted_files if f.is_file()]


def extract_resolution_suffix(scale: str) -> str:
  """Extract height from scale string (e.g. '1920:1080' -> '1080p', '1280x720' -> '720p')."""
  nums: list[str] = re.findall(r"\d+", scale)
  if nums:
    return f"{nums[-1]}p"
  return "compressed"


def main() -> None:
  parser = argparse.ArgumentParser(
    description=(
      "Video compression script using ffmpeg.\n\n"
      "Scans current directory for video files, lets you exclude unwanted ones, "
      "then compresses them with H.265 (configurable) and saves to a dated output folder."
    ),
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog=(
      "Examples:\n"
      "  %(prog)s                          # Use defaults\n"
      "  %(prog)s -o ./my_folder           # Custom output folder (must not exist)\n"
      "  %(prog)s -crf 28 -s 1280:720    # Lower quality, 720p resolution"
    ),
  )

  parser.add_argument(
    "-o", "--output-dir",
    default=None,
    help="Output directory for compressed videos. If omitted, a dated folder like "
         "video_compressed_YYYYMMDD_HHMM is created (reused if it exists). "
         "If provided, the folder MUST NOT already exist.",
  )
  parser.add_argument(
    "-e", "--extensions",
    nargs="+",
    default=DEFAULT_EXTENSIONS,
    help=f"Video file extensions to look for. Default: {', '.join(DEFAULT_EXTENSIONS)}",
  )
  parser.add_argument(
    "-vc", "--video-codec",
    default=DEFAULT_VIDEO_CODEC,
    help=f"Video codec for ffmpeg. Default: {DEFAULT_VIDEO_CODEC}",
  )
  parser.add_argument(
    "-s", "--scale",
    default=DEFAULT_SCALE,
    help=f"Output resolution (ffmpeg scale filter). Default: {DEFAULT_SCALE}",
  )
  parser.add_argument(
    "-crf", "--crf",
    default=DEFAULT_CRF,
    help=f"Constant Rate Factor (quality). Default: {DEFAULT_CRF}",
  )
  parser.add_argument(
    "-ac", "--audio-codec",
    default=DEFAULT_AUDIO_CODEC,
    help=f"Audio codec for ffmpeg. Default: {DEFAULT_AUDIO_CODEC}",
  )
  parser.add_argument(
    "-ab", "--audio-bitrate",
    default=DEFAULT_AUDIO_BITRATE,
    help=f"Audio bitrate. Default: {DEFAULT_AUDIO_BITRATE}",
  )

  args: argparse.Namespace = parser.parse_args()

  # Extract typed arguments to avoid Unknown types from argparse.Namespace
  output_dir_arg: str | None = args.output_dir
  extensions: list[str] = args.extensions
  video_codec: str = args.video_codec
  scale: str = args.scale
  crf: str = args.crf
  audio_codec: str = args.audio_codec
  audio_bitrate: str = args.audio_bitrate

  # Determine output directory
  output_dir: Path
  if output_dir_arg:
    output_dir = Path(output_dir_arg).resolve()
    if output_dir.exists():
      print(f"Error: specified output directory already exists: {output_dir}")
      sys.exit(1)
    output_dir.mkdir(parents=True, exist_ok=False)
  else:
    now_str: str = datetime.now().strftime("%Y%m%d_%H%M")
    output_dir = Path(f"video_compressed_{now_str}").resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

  # Find video files
  video_files: list[Path] = get_video_files(Path.cwd(), extensions)
  if not video_files:
    print(f"No video files found with extensions: {', '.join(extensions)}")
    sys.exit(0)

  # Interactive selection with confirmation loop
  selected: list[Path] = []
  while True:
    print(f"\nFound {len(video_files)} video file(s) in current directory:")
    for idx, f in enumerate(video_files, start=1):
      print(f"  {idx}. {f.name}")

    print("\nEnter numbers of files to EXCLUDE (comma-separated and/or ranges, e.g. 1, 3-5, 8-10).")
    print("Press Enter to keep all files.")
    user_input: str = input("Exclude: ").strip()
    excluded: set[int] = parse_exclude_input(user_input, len(video_files))

    selected = [f for i, f in enumerate(video_files, start=1) if i not in excluded]

    if not selected:
      print("No files selected for compression.")
      retry: str = input("Start over? [Y/n]: ").strip().lower()
      if retry in ("n", "no"):
        print("Exiting.")
        sys.exit(0)
      continue

    print(f"\nSelected {len(selected)} file(s) for compression:")
    for f in selected:
      print(f"  - {f.name}")

    confirm: str = input("\nProceed? [Y/n]: ").strip().lower()
    if confirm in ("n", "no"):
      retry = input("Start over? [Y/n]: ").strip().lower()
      if retry in ("n", "no"):
        print("Exiting.")
        sys.exit(0)
      continue
    break

  print(f"\nCompressing {len(selected)} file(s) to: {output_dir}\n")

  # Prepare resolution suffix for filenames
  res_suffix: str = extract_resolution_suffix(scale)

  # Track overall progress
  total: int = len(selected)
  processed: int = 0
  script_start: float = time.time()
  results: list[tuple[str, int]] = []

  for idx, input_path in enumerate(selected, start=1):
    base_name: str = input_path.stem
    output_name: str = f"{base_name}-{res_suffix}.mp4"
    output_path: Path = output_dir / output_name

    # Build ffmpeg command
    cmd: list[str] = [
      "ffmpeg",
      "-y",
      "-i", str(input_path),
      "-c:v", video_codec,
      "-vf", f"scale={scale}",
      "-crf", str(crf),
      "-c:a", audio_codec,
      "-b:a", audio_bitrate,
      str(output_path),
    ]

    # Popen[bytes] fixes reportMissingTypeArgument; stderr becomes IO[bytes] | None
    process: subprocess.Popen[bytes] = subprocess.Popen(
      cmd,
      stdout=subprocess.DEVNULL,
      stderr=subprocess.PIPE,
    )

    # Read stderr in a separate thread to avoid blocking the pipe buffer
    stderr_lines: list[str] = []

    def read_stderr() -> None:
      # After assert Pylance narrows type to IO[bytes]
      assert process.stderr is not None
      stderr_pipe: IO[bytes] = process.stderr
      try:
        while True:
          line: bytes = stderr_pipe.readline()
          if not line:
            break
          stderr_lines.append(line.decode("utf-8", errors="replace"))
      except (ValueError, OSError):
        pass

    stderr_thread: threading.Thread = threading.Thread(target=read_stderr)
    stderr_thread.start()

    file_start: float = time.time()

    try:
      # Live timer: update every second while process is running
      while process.poll() is None:
        file_elapsed: float = time.time() - file_start
        timer_str: str = format_duration(file_elapsed)
        print(f"\r[{idx}/{total}] Processing: {input_path.name} ({timer_str})", end="", flush=True)
        time.sleep(1)
    except KeyboardInterrupt:
      process.terminate()
      try:
        process.wait(timeout=5)
      except subprocess.TimeoutExpired:
        process.kill()
      raise

    # Clear the timer from the current line and rewrite clean Processing line
    file_elapsed = time.time() - file_start
    padding: str = " " * 30
    print(f"\r[{idx}/{total}] Processing: {input_path.name}{padding}", end="\r")
    print(f"[{idx}/{total}] Processing: {input_path.name}")

    # Wait for stderr thread to finish
    stderr_thread.join()
    stderr: str = "".join(stderr_lines)

    total_elapsed: float = time.time() - script_start

    if process.returncode == 0:
      processed += 1
      size: int = output_path.stat().st_size if output_path.exists() else 0
      results.append((output_name, size))
      print(f"  Done in {format_duration(file_elapsed)} | "
            f"Total elapsed: {format_duration(total_elapsed)} | "
            f"Completed: {processed}/{total}")
    else:
      print(f"  FAILED after {format_duration(file_elapsed)}")
      err_lines: list[str] = stderr.strip().splitlines()
      if err_lines:
        for line in err_lines[-5:]:
          print(f"    {line}")

  # Final summary
  total_elapsed = time.time() - script_start
  print(f"\n{'=' * 50}")
  print(f"Compression complete. Total time: {format_duration(total_elapsed)}")
  print(f"Successfully processed: {processed}/{total}")
  print(f"\nOutput files in {output_dir}:")
  for name, size in results:
    print(f"  {name} - {format_size(size)}")

  if processed < total:
    print(f"\nWarning: {total - processed} file(s) failed.")


if __name__ == "__main__":
  main()