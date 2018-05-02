## overview

-- global resources include preconfigured disk images, disk snapshots, and networks
-- Some resources can be accessed only by resources that are located in the same region. These regional resources include static external IP addresses
-- Other resources can be accessed only by resources that are located in the same zone. These zonal resources include VM instances, their types, and disks.

## projects

- Any GCP resources that you allocate and use must belong to a project. 
- A project is made up of the settings, permissions, and other metadata that describe your applications. 
- The resources that each project contains remain separate across project boundaries; you can only interconnect them through an external network connection.
- Each GCP project has:

	- A project name, which you provide.
	- A project ID, which you can provide or GCP can provide for you.
	- A project number, which GCP provides.

## Ways to interact with the services
- Google Cloud Platform Console
- Command-line interface
	- the Google Cloud SDK provides the gcloud command-line tool
	- GCP also provides Cloud Shell, a browser-based, interactive shell environment for GCP.
- Client libraries

## pricing
- The pricing calculator provides a quick and easy way to estimate what your GCP usage will look like
- The total cost of ownership (TCO) tool evaluates the relative costs for running your compute load in the cloud, and provides a financial estimate. 

## GCP services
- Computing and hosting
- Storage
- Networking
- Big data
- Machine learning

### Computing and hosting services
- Serverless computing: functions as a service (FaaS)
'''
Cloud Functions are a good choice for use cases that include:

Data processing and ETL operations, for scenarios such as video transcoding and IoT streaming data.
Webhooks to respond to HTTP triggers.
Lightweight APIs that comprise loosely coupled logic into applications.
Mobile backend functions.
'''
### Application platform
- Google App Engine is GCP's platform as a service (PaaS). 

### containers
- With container-based computing, you can focus on your application code, instead of on deployments and integration into hosting environments. Google Kubernetes Engine, GCP's containers as a service (CaaS) offering, is built on the open source Kubernetes system, which gives you the flexibility of on-premises or hybrid clouds, in addition to GCP's public cloud infrastructure.

### Virtual Machines
- GCP's unmanaged compute service is Google Compute Engine. You can think of Compute Engine as providing an infrastructure as a service (IaaS), because the system provides a robust computing infrastructure, but you must choose and configure the platform components that you want to use. 




