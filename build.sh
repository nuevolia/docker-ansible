#!/bin/bash
set -e

function build_dockerfile () {
	dist=$1
	echo "* building dist: $dist"

	docker build -t "nuevolia/docker-ansible:$dist" -f "Dockerfile.$dist" .
	docker push nuevolia/docker-ansible:$dist
}
dists=$( ls -1 Dockerfile.* | awk -F'.' '{ print $2 }' )
for dist in $dists
do
        build_dockerfile "$dist"
done
