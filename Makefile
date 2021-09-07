NAME = registry.sensetime.com/industry/noman
COMMIT = $$(git log -1 --pretty=%h)
TIMESTAMP = $$(date +%Y%m%d)
VERSION = v0.1.0
TAG = ${VERSION}-${COMMIT}-${TIMESTAMP}
IMAGE_NAME = ${NAME}:${TAG}

backend-linux-amd64:
	@docker build --rm -t ${IMAGE_NAME}  .
	@docker push ${IMAGE_NAME}

