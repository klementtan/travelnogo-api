docker build -t travelnogo-api .
docker tag travelnogo-api:latest 525805001287.dkr.ecr.ap-southeast-1.amazonaws.com/travelnogo-api:latest
docker push 525805001287.dkr.ecr.ap-southeast-1.amazonaws.com/travelnogo-api:latest