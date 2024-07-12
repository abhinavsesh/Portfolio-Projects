from os import scandir, rename
from os.path import exists, join, splitext
from shutil import move
import logging

# Configuration
source_dir = '/Users/AbhinavSesh/Downloads'
source_dir2='/Users/AbhinavSesh/Desktop'
dest_dirs = {
    "audio_sfx": "/Users/AbhinavSesh/Downloads/AudioSFX",
    "audio_music": "/Users/AbhinavSesh/Downloads/AudioMusic",
    "video": "/Users/AbhinavSesh/Downloads/Videos",
    "image": "/Users/AbhinavSesh/Downloads/Images",
    "document": "/Users/AbhinavSesh/Downloads/Document",
}

# Supported file types
file_extensions = {
    "image": [".jpg", ".jpeg", ".png", ".gif", ".webp", ".tiff", ".psd", ".bmp", ".heif", ".svg", ".ico",".avif",".jfif"],
    "video": [".webm", ".mpg", ".mp4", ".avi", ".wmv", ".mov", ".flv"],
    "audio": [".m4a", ".flac", ".mp3", ".wav", ".wma", ".aac"],
    "document": [".doc", ".docx", ".odt", ".pdf", ".xls", ".xlsx", ".ppt", ".pptx"],
}

def make_unique(dest, name):
    filename, extension = splitext(name)
    counter = 1
    while exists(join(dest, name)):
        name = f"{filename}({counter}){extension}"
        counter += 1
    return name

def move_file(dest, entry):
    name = entry.name
    dest_path = join(dest, name)
    if exists(dest_path):
        name = make_unique(dest, name)
        dest_path = join(dest, name)
    move(entry.path, dest_path)
    logging.info(f"Moved {entry.path} to {dest_path}")

def get_destination_dir(name, size):
    lower_name = name.lower()
    for file_type, extensions in file_extensions.items():
        if any(lower_name.endswith(ext) for ext in extensions):
            if file_type == "audio":
                if size < 10_000_000 or "SFX" in lower_name:
                    return dest_dirs["audio_sfx"]
                else:
                    return dest_dirs["audio_music"]
            return dest_dirs[file_type]
    return None

def on_cleaner():
    with scandir(source_dir) as entries:
        for entry in entries:
            if entry.is_file():
                dest = get_destination_dir(entry.name, entry.stat().st_size)
                if dest:
                    move_file(dest, entry)
    with scandir(source_dir2) as entries:
        for entry in entries:
            if entry.is_file():
                dest = get_destination_dir(entry.name, entry.stat().st_size)
                if dest:
                    move_file(dest, entry)

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    on_cleaner()