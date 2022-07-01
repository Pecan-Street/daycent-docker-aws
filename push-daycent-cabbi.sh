#!/bin/bash

# does an aws docker/ecr cli login using my ~/.aws credentials, builds and tags the image and pushes to the registry
# you'll want to modify it to point at your own registry, obviously.
# Of note!! The AWS ECR Repositry must exist beforehand, or it'll just sit there retrying the uploads until it fails

# log in to ecr
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 712153133523.dkr.ecr.us-east-1.amazonaws.com

# build and tag the image
Docker build -t daycent-cabbi:latest --file Dockerfile . 
docker tag daycent-cabbi:latest 712153133523.dkr.ecr.us-east-1.amazonaws.com/daycent-cabbi:latest

# push to registry
docker push 712153133523.dkr.ecr.us-east-1.amazonaws.com/daycent-cabbi:latest

