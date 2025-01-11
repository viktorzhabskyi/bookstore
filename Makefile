APP = bookstore
REGISTRY = 638693734667.dkr.ecr.us-east-1.amazonaws.com
VERSION=$(shell git rev-parse --short HEAD)
TARGET_OS = linux#linux darwin windows
TARGET_ARCH = amd64#arm64
TARGET_FOLDER := backend_redis
TAG = ${REGISTRY}/${APP}:${TARGET_FOLDER}-${VERSION}-$(TARGET_OS)-${TARGET_ARCH}

image:
	docker build --build-arg TARGET_FOLDER=$(TARGET_FOLDER) \
		--platform $(TARGET_OS)/$(TARGET_ARCH) \
		--file ./build/Dockerfile \
		--tag $(TAG) .

tag:
	@echo $(TAG)

builds:
	$(MAKE) image TARGET_FOLDER=backend_redis
	$(MAKE) image TARGET_FOLDER=backend_rds
	$(MAKE) image TARGET_FOLDER=frontend

docker-login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 638693734667.dkr.ecr.us-east-1.amazonaws.com

push: docker-login
	docker push $(TAG)

clean:
	docker images | grep "bookstore" | awk '{print $3}' | xargs -r docker rmi -f

TAG_RDS = "undefined"
TAG_REDIS = "undefined"
TAG_FRONTEND= "undefined"

up:
	docker-compose -f ./build/docker-compose.yml up -d --force-recreate --build-arg IMAGE_NAME_RDS=$(TAG_RDS) --build-arg IMAGE_NAME_REDIS=$(TAG_REDIS) --build-arg IMAGE_NAME_FRONTEND=$(TAG_FRONTEND)

down:
	docker-compose -f ./build/docker-compose.yml down