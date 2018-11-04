CWD:=$(pwd)
USER_IMAGES=/srv/platform/images/user/
BAND_SET=/srv/platform/images/band_set/
BAND_BASE=/srv/platform/build/band-framework

build:
	docker build -t theia . --no-cache

push-latest:
	docker tag theia rockstat/theia-ide:latest
	docker push rockstat/theia-ide:latest

push-dev:
	docker tag theia rockstat/theia-ide:dev
	docker push rockstat/theia-ide:dev

run_dev:
	docker run -it --rm -p 8799:8000 \
		-v "$(USER_IMAGES):/home/theia/project/my_images:cached" \
		-v "$(BAND_SET):/home/theia/project/sources/band_set:cached" \
		-v "$(BAND_BASE):/home/theia/project/sources/band_base:cached" \
		rockstat/theia-ide:dev

sync:
	source .env && rsync --exclude=.git -a . "$$BUILDER_USER@$$BUILDER:~/build/theia"

build_on_common: sync_to_common
	ssh root@common.dg02.ru "cd theia && make build"