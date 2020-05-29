# Deploying with kubernetes

## Updating change
`./deploy.sh`

## Running commands

`kubectl exec -it {pod name} -- /bin/bash`



## Tail logs
`kubectl logs --follow -l app=travelnogoq`

## DB migrate
kubectl exec -it travelnogo-deployment-5c8fcf74df-9rzks -- rails db:migrate RAILS_ENV=production