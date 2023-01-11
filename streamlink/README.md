# Streamlink container

This containers runs a streamlink session in order to quickly download a stream 'on-the-go'.

You can build it on a alpine base for performance, or on top of debian for stability. Just symlink the right Dockerfile to `./Dockerfile`.

It is **only** meant to be run with `-o` output, as vlc will complain to open streams in any other way as root _(inside the container)_.

Plugins added to the `plugins` folder will be automatically installed into the image. One comes already included ;)

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
or using the `run.sh` script provided and symlink that on `$PATH`.


