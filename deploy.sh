docker build -t charlieouyang/salsa:latest -t charlieouyang/salsa:$SHA .
docker build -t charlieouyang/salsa_ui:latest -t charlieouyang/salsa_ui:$SHA ./salsa_ui

docker push charlieouyang/salsa:latest
docker push charlieouyang/salsa:$SHA
docker push charlieouyang/salsa_ui:latest
docker push charlieouyang/salsa_ui:$SHA

kubectl apply -f ops/k8s

kubectl set image deployments/web-deployment web=charlieouyang/salsa:$SHA
kubectl set image deployments/ui-deployment ui=charlieouyang/salsa_ui:$SHA

echo 'Finished deployment!'