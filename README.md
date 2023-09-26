# curl-and-git-updater
This is a shell script that provide automatic update of url file and github repo from a source file. 

Format of the file liste.txt:
	  <directory> <url>
Directories are created if they don't exist.

Options :
	--clone   only clone Git repositories
	--pull    only pull Git repositories
	--curl    only download files using curl
	--all     clone or pull Git repositories and download files using curl
	-h, --help  display this help and exit

Featur to add : 
  - find a way to check if there is any changes for url file. 
