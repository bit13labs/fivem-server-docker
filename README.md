# FIVEM SERVER

This is a FiveM server container.

### WHERE TO GET SERVER LICENSE KEY
### RUNNING THE SERVER
```shell
docker run -d \
	--restart unless-stopped \
	--name ${BUILD_PROJECT} \
	-e TZ=America_Chicago \
	-e RCON_PASSWORD="<rcon password>" \
	-e SERVER_NAME="My Super Cool FiveM Server" \
	-e SERVER_TAGS="dev,test" \
	-e SERVER_LICENSE_KEY="<server license key>" \
	-v /mnt/data/${BUILD_PROJECT}:/data \
	-t "camalot/fivem-server";
```