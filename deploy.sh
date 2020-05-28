docker build -t travelnogo .
docker tag travelnogo:latest gcr.io/travelnogo/travelnogo
docker push gcr.io/travelnogo/travelnogo
kubectl delete -f deployment.yml
kubectl delete -f redis-master.yml
kubectl apply -f deployment.yml
kubectl apply -f redis-master.yml

