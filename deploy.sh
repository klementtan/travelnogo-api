docker build -t travelnogo .
docker tag travelnogo:latest gcr.io/travelnogo/travelnogo
docker push gcr.io/travelnogo/travelnogo
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

