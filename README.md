# SimpleSvn
a simple svn implement. Supports directly viewing files, creating new folders, uploading files, downloading files, and deleting files on the svn server.

# command
- list [url]
- cd $int (-1 is ..)
- mkdir $name
- upload $file
- download $int
- del $int
- exit

# dependencies
To rely on the svn command-line tool, you need to first configure the svn tool address, svn server address, download path (where to save the downloaded file), and terminal character encoding in the config.toml file.
