# Istio Gateway Lab

Configure service mesh gateway to control traffic that entering mesh.


## Gateway
Review the following Istio's Gateway rule configuration file [ingress-gateway.yml](../istio-files/ingress-gateway.yml)  to create Istio Gateway.

Run oc apply command to create Istio Gateway.
```
oc apply -f istio-files/ingress-gateway.yml -n $USERID
```

Sample outout
```
gateway.networking.istio.io/ingress-gateway created
```

## Routing by incoming HTTP header
### Destination Rule
Review the following Istio's destination rule configuration file [destination-rule-frontend-v1-v2.yml](../istio-files/destination-rule-frontend-v1-v2.yml)  to define subset called v1 and v2 by matching label "app" and "version"

Run oc apply command to create Istio Gateway.
```
oc apply -f istio-files/destination-rule-frontend-v1-v2.yml -n $USERID
```

Sample outout
```
destinationrule.networking.istio.io/frontend created
```

### Virtual Service
Review the following Istio's  virtual service configuration file [virtual-service-frontend-header-foo-bar-to-v1.yml](../istio-files/virtual-service-frontend-header-foo-bar-to-v1) to routing request to v1 if request container header name foo with value bar

```
...
- match:
    - headers:
        foo:
          exact: bar
    route:
    - destination:
        host: frontend
        subset: v1
...
```

Run oc apply command to apply Istio virtual service policy.
```
oc apply -f istio-files/virtual-service-frontend-header-foo-bar-to-v1.yml -n $USERID
```

Sample output
```
virtualservice.networking.istio.io/frontend created
```

## Test
Get URL of Istio Gateway by using following command
```
export GATEWAY_URL=$(oc -n $USERID-istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

```
Verify that environment variable GATEWAY is set correctly.
```
echo $GATEWAY
```
Sample output
```
istio-ingressgateway-user1-istio-system.apps.cluster-bkk77-eeb3.bkk77-eeb3.example.opentlc.com
```

Test with cURL by setting header name foo with value bar. Response will always from Frontend v1
```
curl -v -H foo:bar $GATEWAY_URL
```

Test again witout specified parameter -H. Response will always from Frontend v2

## Remove Istio Policy
Run oc delete command to remove Istio policy.

```
oc delete -f istio-files/ingress-gateway.yml -n $USERID
oc delete -f istio-files/destination-rule-frontend-v1-v2.yml -n $USERID
oc delete -f istio-files/virtual-service-frontend-header-foo-bar-to-v1.yml -n $USERID

```