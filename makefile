CWD:=$(pwd)
USER_IMAGES:="/srv/platform/images/user/"
BAND_SET:="/srv/platform/images/band_set/"
BAND_BASE:="/srv/platform/build/band-framework"

build:
	docker build -t madiedinro/theia-rst .

run_dev:
	docker run -it --rm -p 8799:8000 \
		-v "$(USER_IMAGES):/home/theia/project/my_images:cached" \
		-v "$(BAND_SET):/home/theia/project/sources/band_set:cached" \
		-v "$(BAND_BASE):/home/theia/project/sources/band_base:cached" \
		madiedinro/theia-rst

sync_test:
	rsync -a --exclude=./theia --exclude=./.zprezto  --exclude=./workspace . root@common.dg02.ru:~/theia

