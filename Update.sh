#!/bin/zsh
#!/bin/zsh

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

while read -r line; do
    [[ $line == \#* ]] && continue
    dir=${line%% *}
    url=${line#* }
    if [[ -d "$dir" && $url == *.git ]]; then
        if [[ $1 == "--pull" || $1 == "--all" ]]; then
            cd "$dir"
            print -P "%B%F{226}${dir##*/}%f%b"
            git pull
        fi
    elif [[ $1 == "--clone" || $1 == "--all" && $url == *.git ]]; then
        mkdir -p "$(dirname "$dir")"
        cd "$(dirname "$dir")"
        print -P "%B%F{226}${url##*/}%f%b"
        git clone "$url"
    elif [[ $1 == "--curl" || $1 == "--all" && $url != *.git ]]; then
        mkdir -p "$dir"
        cd "$dir"
        if [[ -f "${url##*/}" ]]; then
            print -P "%B%F{green}File ${url##*/} already exists in $dir%f%b"
        else
            print -P "%B%F{226}${url##*/}%f%b"
            curl -O "$url"
        fi
    fi
done < liste.txt
