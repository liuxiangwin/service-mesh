# Advanced Development with ​Red Hat 3scale API Management Assignment

Table of Content

 * [Introduction](#introduction)
 * [API Service Setup section](#api-service-setup-section)
 * [Methods, Metrics, Rate Limits Setup section](#methods-metrics-rate-limits-setup-section)
    - [Catalog Application](#catalog-application)
    - [Inventory Application](#inventory-application)
 * [User Signup Setup section](#user-signup-setup-section)
    - [Development Portal and API Docs section](#development-portal-and-api-docs-section)
    - [Development Portal](#development-portal)
 * [API Docs](#api-docs)
 * [Test and Result Examples](#test-and-result-examples)
 * [Authors](#authors)


## Introduction
Scenario for assignment is developing a new online retail platform branded "CoolStore" for WebRetail Inc., through which their partners can provide a catalog and inventory to sell products through the platform.

## API Service Setup section

Following shell scripts are used for  provisioning Catalog and Inventory Service on OpenShift

* Create Apps and their config maps: [setup.sh](scripts/setup.sh)
* Label and annotate service for enable 3Scale auto-discovery: [label-and-annotate-svc.sh](scripts/label-and-annotate-svc.sh)
* Route for APICast (Automatic route creation is disabled): [create-route.sh](scripts/create-route.sh)


## Methods, Metrics, Rate Limits Setup section

Each application contains 2 plans. Basic and Premium. Basic plan will limit for 5 call per hour and only Read (GET) operation is enabled.

### Catalog Application

Metrics for catalog application
![Catalog Metrics](images/catalog-metrics.png)

Plans for catalog application
Remark that "public" features is added. This feature is used by liquid script to control portal to display only application with this feature.

Basic plan with rate limit and enable only "Read Catalog"
![Catalog Basic Plan](images/catalog-basic-plan.png)

Premium plan
![Catalog Premium Plan](images/catalog-premium-plan.png)

Enable approval for premium plan
![Catalog Premium with Approval](images/catalog-premium-approval.png)

Mapping metrics with mapping rules
![Mapping Rules](images/catalog-mapping-rules.png)

Analytics information will be mapped by each operation
![catalog-analytic](images/catalog-analytics.png)

### Inventory Application
3Scale configuration for Inventory application is very same with Catalog application. 
Currently Inventory application contains only read operation.

![catalog-analytic](images/inventory-analytics.png)

## User Signup Setup section
New partial [public-only-signup-partial.liquid](liquid/cpublic-only-signup-partial.liquid) is created for mulitple signup and display only API with feature name "public"

Following code are for filter to display only feature name "public"

```
...
{% for service in provider.services %}
        {% for feature in service.features %}
        {% if feature.system_name contains 'public' %}
        <h2> {{ service.name }} </h2>
...
```

Developer Portal plan show only API with feature name "public" and can register multiple APIs
![Plan](images/developer-portal-plan.png)


## Development Portal and API Docs section
### Development Portal
For custom look & feel UI, Create new layout [coolstore-layout.liquid](liquid/coolstore-layout.liquid) form default layout and change stylesheet to display new banner.

```
...
<style>
    body {
      background-color: #7F8F00;
      /* fallback */
      background-color: rgba(131, 146, 16, 0.98);
    }

    .page-header {
      background-image: url(/images/coolstore.png);
    }
  </style>
...
```

Banner coolstore.png need to be uploaded
![Upload Banner](images/upload-banner.png)


Set default Homepage to use our layout
![Set Layout](images/homepage-layout.png)

Homepage is slighlty modified for display WebRetail name.
```
...
<div class="row">
      <div class="col-md-12">
        <h1>Web Retail API</h1>
         <p>
          <i class="fa fa-sign-in fa-3x pull-left"></i>
          Powered by: <img src="{{ provider.logo_url }}"/>
          </p> 
      </div>
    </div>
...
```

Developer Portal with new banner
![Banner](images/developer-portal-banner.png)

### API Docs
3Scale support OpenAPI/Swagger with ActiveDocs. Following show activeDocs for Inventory

![activeDocs](images/active-docs.png)

For Developer Portal to display correct authentication information which configured by 3Scale. Paramater named "x-data-threescale-name" need to be added.

```
...
"parameters": [
          {
                    "name": "user-key",
                    "in": "header",
                    "description": "Your API access key",
                    "required": true,
                    "x-data-threescale-name": "user_keys",
                    "type": "string"
                }
         
        ],
...
```

Swagger's host and scheme also needed to be modified according to your protocol and route host name.

```
...
"schemes": [
    "https"
  ],
  "host": "catalog-service-production-apicast-ocp20.apps.4865.open.redhat.com:443",
...
```

By default, Developer Portal show only the 1st API docs. New partial [swagger-ui-partial.liquid](liquid/swagger-ui-partial.liquid)  is created to support for display multiple OpenAPI/Swagger doc.

Modified original Documentation pages to include above partail.

```
...
{% include 'shared/swagger_ui' %}
...
```

Document Page of Developer Portal 

![OpenAPI Docs](images/developer-portal-documentation.png)

## Test and Result Examples



Example cURL command.

```
# Read Inventory by Id
curl -X GET --header 'Accept: application/json' \
--header 'user-key: f37f22419dae4cb306ac36830d2be369' \
'https://inventory-service-production-apicast-ocp20.apps.4865.open.redhat.com:443/inventory/329299'

# Read All Products
curl -X GET --header 'Accept: application/json' \
--header 'user-key: 1f72be64429e085ce3f201f20de2264f' \
 'https://catalog-service-production-apicast-ocp20.apps.4865.open.redhat.com:443/products'

# Read Product by Id
curl -X GET --header 'Accept: application/json' \
--header 'user-key: 1f72be64429e085ce3f201f20de2264f' \
 'https://catalog-service-production-apicast-ocp20.apps.4865.open.redhat.com:443/product/329299'

# Create Product
 curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ \
   "itemId": 777777, \
   "name": "Red Hat Fedora", \
   "desc": "Official Red Hat Fedora", \
   "price": 10000000000 \
 }' 'https://catalog-service-production-apicast-ocp20.apps.4865.open.redhat.com:443/product'

```
User with basic plan can call service only 5 hits/hour. Follow show error when limit is exceeded.

![429 Too Many Requests](images/limit-exceeded.png)

User with Basic can use only READ (GET) operation.

```
curl -X POST -v --header 'Accept: application/json' \
--header 'user-key: 1f72be64429e085ce3f201f20de2264f' \
 'https://catalog-service-production-apicast-ocp20.apps.4865.open.redhat.com:443/product'
```
Response when user does not have rights to Create (POST)

![403 Fobidden](images/basic-user-cannot-post.png)

## Authors

* **Voravit** 

