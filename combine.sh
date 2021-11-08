VERSION=v4.0.15
docker manifest create schnell18/pd-dev:$VERSION
    --amend schnell18/schnell18/pd-dev:$VERSION-arm64 \
    --amend schnell18/schnell18/pd-dev:$VERSION-amd64

docker manifest push schnell18/pd-dev:$VERSION
