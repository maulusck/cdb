# Streamlink container

This containers runs a streamlink session in order to quickly download a stream 'on-the-go'.

It is **only** meant to be run with `-o` output, as vlc will complain to open streams in any other way as root _(inside the container)_.

#### USAGE
```
podman run --rm -it -v <your_destination_directory>:/<download_dir> streamlink-otg \
	-o /<download_dir>/<filename> <stream URL> <quality>
```

You can also use it as a standalone binary, like `podman run --rm -it streamlink-otg --help`, keeping in consideration the limitations above.

Also consider aliasing it to a default download directory, i.e.:
```
alias streamlink='podman run --rm -it -v <default_download_directory:/<download_dir> -o /<download_dir>/stream-$(date -Iseconds | awk -F "+" \'{print$1}\').mp4 streamlink-otg'
```

That's it for now.
