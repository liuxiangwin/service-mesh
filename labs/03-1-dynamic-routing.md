# Dynamic Routing Lab

Configure service mesh route rules to dynamically route and shape traffic between services


## Traffic Management
Routing within Service Mesh can be controlled by using Virtual Service and Routing Rules.

### Define Routing Rules
Service Mesh Route rules control how requests are routed within service mesh.

Requests can be routed based on the source and destination, HTTP header fields, and weights associated with individual service versions. For example, a route rule could route requests to different versions of a service.

VirtualService defines a set of traffic routing rules to apply when a host is addressed. Each routing rule defines matching criteria for traffic of a specific protocol. If the traffic is matched, then it is sent to a named destination service (or subset/version of it) defined in the registry. The source of traffic can also be matched in a routing rule. This allows routing to be customized for specific client contexts.

DestinationRule defines policies that apply to traffic intended for a service after routing has occurred. These rules specify configuration for load balancing, connection pool size from the sidecar, and outlier detection settings to detect and evict unhealthy hosts from the load-balancing pool.

### Destination Rule
Review the following Istio's destination rule configuration file  (...) to define subset called v1 and v2 by matching label "app" and "version"

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
oc apply -f istio-files/a-b-destination-rules.yml -n $USERID
oc apply -f istio-files/a-b-virtaul-service.yml -n $USERID

```

Sample outout
```
destinationrule.networking.istio.io/backend created
virtualservice.networking.istio.io/backend-virtual-service created

```

### Test
Test A/B deployment by run following scripts
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

### Remove Istio Policy
Run oc delete command to remove Istio policy.

```
oc delete -f istio-files/a-b-destination-rules.yml -n $USERID
oc delete -f istio-files/a-b-virtaul-service.yml -n $USERID

```

## Timeout and redirect
Let's say that 6 sec respond time of backend v2 is too long. If frontend wait more than 3 sec, frontend will receive HTTP code 504

We can do this by following virtual service.
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

Replace virtual service by 
```
oc apply -f istio-files/a-b-virtual-service-with-timeout.yml -n $USERID

```

Test again with cURL and check for 504 response code from backend version 2.0.0
```
curl $FRONTEND_URL
```

Result
```
Frontend version: 1.0.0 => [Backend: http://backend:8080, Response: 504, Body: upstream request timeout]
```
