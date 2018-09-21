CWD:=$(pwd)
USER_IMAGES:="$(CWD)/../user"

build:
	docker build -t madiedinro/theia-rst .

run_dev:
	docker run -it --rm -p 8000:8000 --net custom \
		-v "$(USER_IMAGES):/home/theia/project:cached" \
		theia2
