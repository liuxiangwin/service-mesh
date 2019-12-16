# Dynamic Routing Lab

Configure service mesh route rules to dynamically route and shape traffic between services


## Traffic Management
Routing within Service Mesh can be controlled by using Virtual Service and Routing Rules.

Service Mesh Route rules control how requests are routed within service mesh.

Requests can be routed based on the source and destination, HTTP header fields, and weights associated with individual service versions. For example, a route rule could route requests to different versions of a service.

VirtualService defines a set of traffic routing rules to apply when a host is addressed. Each routing rule defines matching criteria for traffic of a specific protocol. If the traffic is matched, then it is sent to a named destination service (or subset/version of it) defined in the registry. The source of traffic can also be matched in a routing rule. This allows routing to be customized for specific client contexts.

DestinationRule defines policies that apply to traffic intended for a service after routing has occurred. These rules specify configuration for load balancing, connection pool size from the sidecar, and outlier detection settings to detect and evict unhealthy hosts from the load-balancing pool.

## Traffic splitting by percentage
### Destination Rule
Review the following Istio's destination rule configuration file [destination-rule-backend-v1-v2.yml](../istio-files/destination-rule-backend-v1-v2.yml)  to define subset called v1 and v2 by matching label "app" and "version"

```
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: backend
spec:
  host: backend
  subsets:
  - name: v1
    labels:
      app: backend
      version: 1.0.0
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  - name: v2
    labels:
      app: backend
      version: 2.0.0
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
```
### Virtual Service
Review the following Istio's  virtual service configuration file [virtual-service-backend-v1-v2-80-20.yml](../istio-files/virtual-service-backend-v1-v2-80-20.yml) to route 80% of traffic to version 1.0.0 and 20% of traffic to version 2.0.0

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: backend-virtual-service
spec:
  hosts:
  - backend
  http:
  - route:
    - destination:
        host: backend
        subset: v1
      weight: 80
    - destination:
        host: backend
        subset: v2
      weight: 20
```

### Apply Istio Policy for A/B deployment
Run oc apply command to apply Istio policy.

```
oc apply -f istio-files/destination-rule-backend-v1-v2.yml -n $USERID
oc apply -f istio-files/virtual-service-backend-v1-v2-80-20.yml -n $USERID

```

Sample outout
```
destinationrule.networking.istio.io/backend created
virtualservice.networking.istio.io/backend-virtual-service created

```

### Test
Test A/B deployment by run [run-50.sh](../scripts/run-50.sh)
```
scripts/run-50.sh

```

Sample output

```
...
Backend:2.0.0 Elapsed Time:5.873382 sec
Backend:1.0.0 Elapsed Time:0.868324 sec
Backend:1.0.0 Elapsed Time:0.813940 sec
Backend:1.0.0 Elapsed Time:0.793226 sec
Backend:1.0.0 Elapsed Time:0.849677 sec
========================================================
Total Request: 50
Version 1.0.0: 43
Version 2.0.0: 7
========================================================
```
You can also check this splitting traffic with Kiali console.
![Kiali Graph 80-20](../images/kiali-graph-80-20.png)

## Timeout
Let's say that 6 sec respond time of backend v2 is too long. If frontend wait more than 3 sec, frontend will receive HTTP code 504

Review the following Istio's  virtual service configuration file [virtual-service-backend-v1-v2-50-50-3s-timeout.yml](../istio-files/virtual-service-backend-v1-v2-50-50-3s-timeout.yml) to set timeout to 6 sec

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: backend-virtual-service
spec:
  hosts:
  - backend
  http:
  - timeout: 3s
    route:
    - destination:
        host: backend
        subset: v1
      weight: 50
    - destination:
        host: backend
        subset: v2
      weight: 50
```

Run oc apply command to apply Istio policy.

```
oc apply -f istio-files/destination-rule-backend-v1-v2.yml -n $USERID
oc apply -f istio-files/virtual-service-backend-v1-v2-50-50-3s-timeout.yml -n $USERID

```

Sample outout
```
destinationrule.networking.istio.io/backend created
virtualservice.networking.istio.io/backend-virtual-service created

```

Test again with cURL and check for 504 response code from backend version 2.0.0
```
curl $FRONTEND_URL
```

Result
```
Frontend version: 1.0.0 => [Backend: http://backend:8080, Response: 504, Body: upstream request timeout]
```

Run [run-50.shj](../scripts/run-50.sh)
```
scripts/run-50.sh
```

Sample output
```
Backend:, Response Code: 504, Host:, Elapsed Time:3.878352 sec
Backend:1.0.0, Response Code: 200, Host:backend-v1-84b98cf86c-hjf65, Elapsed Time:1.558571 sec
Backend:, Response Code: 504, Host:, Elapsed Time:3.556231 sec
Backend:1.0.0, Response Code: 200, Host:backend-v1-84b98cf86c-hjf65, Elapsed Time:1.681229 sec
Backend:1.0.0, Response Code: 200, Host:backend-v1-84b98cf86c-hjf65, Elapsed Time:1.573688 sec
Backend:, Response Code: 504, Host:, Elapsed Time:4.295051 sec
```

Check Graph in Kiali Console with Response time.
![](../images/kiali-graph-timeout.png)

## Remove Istio Policy
Run oc delete command to remove Istio policy.

```
oc delete -f istio-files/virtual-service-backend-v1-v2-80-20.yml -n $USERID
oc delete -f istio-files/destination-rule-backend-v1-v2.yml -n $USERID

```

<!-- ## Traffic splitting by HTTP header
### Virtual Service
Review the following Istio's  virtual service configuration file (...) to route 80% of traffic to version 1.0.0 and 20% of traffic to version 2.0.0
```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: backend-virtual-service
spec:
  hosts:
  - backend
  http:
  - match:
    - headers:
        baggage-user-agent:
          regex: .*Firefox.*
    route:
    - destination:
        host: backend
        subset: v1
  - route:
    - destination:
        host: backend
        subset: v2
```

### Apply Istio Policy for A/B deployment
Run oc apply command to apply Istio policy.

```
oc apply -f istio-files/a-b-destination-rules.yml -n $USERID
oc apply -f istio-files/virtual-service-firefox-backend-v1.yml -n $USERID

```

Sample outout
```
destinationrule.networking.istio.io/backend created
virtualservice.networking.istio.io/backend-virtual-service created

```
### Test
Test cURL with User-Agent is set to Firefox
```
curl -H "User-Agent:Firefox" $FRONTEND_URL

``` -->

<!-- export GATEWAY_URL=$(oc -n $USERID-istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}') -->