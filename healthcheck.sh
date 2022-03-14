echo "executing health check it might take a while"
sleep 120
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl myjavaapp-myapp:8080

if [ $? -eq 0 ]
then
 echo "The Deployment is success...Application Health is Good"
else
  helm rollback myjavaapp 
fi
