# Service Mesh Workshop

Table of Content

 * [Introduction](#introduction)
 * [Install Operators](labs/00-install-operators.md)
 * [Configure Control Plane](labs/01-install-service-mesh.md)
 * [Microservices Deployment](labs/02-microservice-deployment.md)
 * [Observability with Kiali and Jaeger](labs/03-observability.md)
 * [Traffic Management](labs/04-traffic-management.md)
 * [Istio Gateway - Entering the Mesh](labs/05-ingress.md)
 * [Control traffic with timeout](labs/06-timeout.md)
 * [Service Resilience with Circuit Breaker](labs/07-circuit-breaker.md)
 * [Secure with Mutual TLS](labs/08-securing-with-mTLS.md)

## Authors

* **Voravit L** 

The Service Mesh installation process uses the OperatorHub to install the ServiceMeshControlPlane custom resource definition within the openshift-operators project. The Red Hat OpenShift Service Mesh defines and monitors the ServiceMeshControlPlane related to the deployment, update, and deletion of the control plane.

Starting with Red Hat OpenShift Service Mesh 1.0.1, you must install the Elasticsearch Operator, the Jaeger Operator, and the Kiali Operator before the Red Hat OpenShift Service Mesh Operator can install the control plane.

