# Service Resilience by Circuit Breaker Lab



## Setup
Setup microservices app as follow:

![](../images/microservices-circuit-breaker.png)

Remove backend-v2 and scale backend-v1 to 3 pods. 

```
oc delete -f ocp/backend-v2-deployment.yml -n $USERID
oc scale deployment backend-v1 --replicas=3 -n $USERID
watch oc get pods -n $USERID
# Wait until all backend-v1 pods status are Runnings and all container in pods are ready (2/2)
```

Sample output

```
NAME                          READY   STATUS    RESTARTS   AGE
backend-v1-6ddf9c7dcf-sqxqz   2/2     Running   0          8h
backend-v1-6ddf9c7dcf-vm6kb   2/2     Running   0          8h
backend-v1-6ddf9c7dcf-x6gkh   2/2     Running   0          8h
frontend-v1-655f4478c-wn7wr   2/2     Running   0          9h
```
You can also scaleup pod by using OpenShift Web Console. Select Workloads->Deployment on the left-menu. Then select backend-v1

![Deploymennt](../images/openshift-console-deployment.png)

Scale pod to 3 by click upper arrow icon.

![Scaleup](../images/openshift-console-scaleup.png)

We will force one backend-v1 pod to return 504. This can be done by rsh into pod the curl to /stop (backend-v1 will always return 504 after receiving /stop. This is for demo)

Select one pod and connect to pod's terminal by using following oc command or OpenShift Web Console.

```
oc rsh <pod name> -n $USERID
# After you get prompt run following command
curl http://localhost:8080/stop
exit
```

You can also use OpenShift Web Console. Select Workloads->Pods on the left-menu. Then select one of backend-v1 pods.

![Select pod](../images/openshift-console-pod.png)

select Terminal tab then run cURL command

![Terminal](../images/openshift-console-terminal.png)

Test with [run50.sh](../scripts/run-50.sh) and check that with averagely 3 requests 1 request will response with response code 504
```
scripts/run-50.sh
```

Sample output
```
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-x6gkh, Elapsed Time:1.132765 sec
Backend:v1, Response Code: 504, Host:, Elapsed Time:0.134960 sec
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-sqxqz, Elapsed Time:1.022941 sec
Backend:v1, Response Code: 504, Host:, Elapsed Time:0.117325 sec
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-x6gkh, Elapsed Time:0.787738 sec
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-sqxqz, Elapsed Time:1.004579 sec
Backend:v1, Response Code: 504, Host:, Elapsed Time:0.114131 sec
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-x6gkh, Elapsed Time:0.964214 sec
Backend:v1, Response Code: 200, Host:backend-v1-6ddf9c7dcf-sqxqz, Elapsed Time:1.043541 sec
Backend:v1, Response Code: 504, Host:, Elapsed Time:0.122031 sec
```

## Circuit Breaker and Pool Ejection
Review the following Istio's destination rule configuration file [destination-rule-backend-circuit-breaker-with-pool-ejection.yml](../istio-files/destination-rule-backend-circuit-breaker-with-pool-ejection.yml)  to define circuit breaker and pool ejection with following configuration.

```
...
trafficPolicy:
    loadBalancer:
      simple: ROUND_ROBIN
    tls:
      mode: ISTIO_MUTUAL
...
```

Apply destination rule to enable mTLS for backend service

```

oc apply -f istio-files/destination-rule-backend-v1-v2-mtls.yml -n $USERID
```

Sample output

```
destinationrule.networking.istio.io/backend configured
```

## Test


## Clean Up
Run oc delete command to remove Istio policy.

```
oc delete -f istio-files/destination-rule-backend-circuit-breaker-with-pool-ejection.yml -n $USERID
oc delete -f istio-files/virtual-service-backend.yml -n $USERID
```

<!-- Remove all pods
```
oc delete -f ocp/backend-v1-deployment.yml -n $USERID
oc delete -f ocp/backend-service.yml -n $USERID
oc delete -f ocp/frontend-v1-deployment.yml -n $USERID
oc delete -f ocp/frontend-service.yml -n $USERID
oc delete -f ocp/frontend-route.yml -n $USERID
``` -->
