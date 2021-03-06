# godot-docker-android
Docker image for Godot android builds, current Godot version is `3.4.4`

Uses [lerneca/godot](https://hub.docker.com/repository/docker/lerneca/godot) image as base layer (Alpine Linux + GLIBC). 
Contains baked-in debug keystore.

## Example usage:

Android debug build
``` 
docker run -v $(pwd):/root/godot -v /tmp:/root/output lerneca/godot-android godot -v --export-debug Android /root/output/MyApp.apk
``` 
Builds available at: https://hub.docker.com/r/lerneca/godot-android

Parent image source at: https://github.com/lerneca/godot-docker
