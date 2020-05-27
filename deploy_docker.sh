docker build -t travelnogo .
docker tag travelnogo:latest gcr.io/$PROJECT/travelnogo
docker push gcr.io/$PROJECT/travelnogo

