#!/bin/zsh

# Display help and exit if no options or help option is provided
if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]]; then
    cat <<-END
	Usage: $0 [OPTION]...
	Clone or pull repositories and/or download files from a list in file liste.txt.

	  --clone   only clone or download Git repositories
	  --pull    only pull Git repositories
	  --curl    only download files using curl
	  --all     clone or pull Git repositories and download files using curl
	  -h, --help  display this help and exit

	Format of the file liste.txt:
	  <directory> <url>
	  Directories are created if they don't exist.
	END
    exit 0
fi

# Check if `liste.txt` exists
if [[ ! -f liste.txt ]]; then
    echo "Error: The file 'liste.txt' was not found."
    exit 1
fi

# Check if required tools are installed
command -v git >/dev/null 2>&1 || { echo "Error: git is not installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "Error: curl is not installed."; exit 1; }

# Read the file line by line
while read -r line || [[ -n $line ]]; do
    # Skip comments or empty lines
    [[ $line == \#* || -z $line ]] && continue

    # Extract directories and URLs
    dir=${line%% *}
    url=${line#* }

    if [[ $1 == "--curl" || $1 == "--all" ]]; then
        if [[ $url != *.git ]]; then
            # Handle files to download via curl
            mkdir -p "$dir"
            cd "$dir"
            if [[ -f "${url##*/}" ]]; then
                print -P "%B%F{green}File ${url##*/} already exists in $dir%f%b"
            else
                print -P "%B%F{226}Downloading file: ${url##*/}%f%b"
                curl -O "$url" || echo "Error: Failed to download $url"
            fi
            cd - >/dev/null
            continue
        fi
    fi

    # Handle Git repositories
    if [[ $url == *.git ]]; then
        if [[ $1 == "--pull" || $1 == "--all" ]]; then
            if [[ -d "$dir" ]]; then
                # If the directory exists we can pull
                cd "$dir"
                print -P "%B%F{226}Updating repository: ${dir##*/}%f%b"
                git pull || echo "Error: Failed to update $dir"
                cd - >/dev/null
                continue
            fi
            continue
        elif [[ $1 == "--clone" || $1 == "--all" ]]; then
            # If the directory does not exist and a clone is required
            mkdir -p "$(dirname "$dir")"
            cd "$(dirname "$dir")"
            print -P "%B%F{226}Cloning repository: ${url##*/}%f%b"
            git clone "$url" || echo "Error: Failed to clone $url"
            cd - >/dev/null
        fi
    fi
done < liste.txt
