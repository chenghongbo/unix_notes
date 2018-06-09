## overview

-- global resources include:
	preconfigured disk images
	disk snapshots
	networks
	instance templates
	VPC network
	Firewalls
	Routes
	
-- regional resources include 
	static external IP addresses
	subnets
	Regional managed instance groups
-- zonal resources include
	VM instances and their types
	disks
	Zonal managed instance groups
-- Regional resources can be used by any resources in that region, regardless of zone, while zonal resources can only be used by other resources in the same zone
-- Notice that each region is independent of other regions and each zone is isolated from other zones in the same region.
-- Certain resources, such as static IPs, images, firewall rules, and VPC networks, have defined project-wide quota limits and per-region quota limits. 

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

## Storage Services

- Cloud SQL. SQL databases, MySQL or PostGreSQL
- Cloud Spanner. transactional consistency at global scale, schemas, SQL querying, and automatics synchronous replication for hight availability.
- Cloud datastore. NoSQL data storage
- Cloud Bigtable. NoSQL data storage
- Cloud Storage. Object storage (like S3 in AWS)
	- multi-Regional provides maximum availability and geo-redundancy
	- regional provides high availability and a localized storage location
	- Nearline provides low-cost archival storage ideal for data accessed less than once a month
	- Coldline provides the lowest-cost archival storage for backup and disaster recovery
- Persistent Disks. Block storage for computer engine. PD or SSD PD

## networking
two types of VPC networks
- auto mode
When an auto mode VPC network is created, one subnet from each region is automatically created within it. These automatically created subnets use a set of predefined IP ranges which fit within the 10.128.0.0/9 CIDR block.
- custom mode
When a custom mode VPC network is created, no subnets are automatically created. This type of network provides you with complete control over its subnets and IP ranges. You decide which subnets to create, in regions you choose, and using IP ranges you specify.
- Each project starts with a default auto mode network.

## big data
- BigQuery 
Google's serverless, highly scalable, low cost enterprise data warehouse designed to make all your data analysts productive. Because there is no infrastructure to manage, you can focus on analyzing data to find meaningful insights using familiar SQL and you don't need a database administrator. BigQuery enables you to analyze all your data by creating a logical data warehouse over managed, columnar storage as well as data from object storage, and spreadsheets. BigQuery makes it easy to securely share insights within your organization and beyond as datasets, queries, spreadsheets and reports. BigQuery allows organizations to capture and analyze data in real-time using its powerful streaming ingestion capability so that your insights are always current. BigQuery is free for up to 1TB of data analyzed each month and 10GB of data stored.

- Cloud Dataproc 
A fast, easy-to-use, fully-managed cloud service for running Apache Spark and Apache Hadoop clusters in a simpler, more cost-efficient way. Operations that used to take hours or days take seconds or minutes instead, and you pay only for the resources you use (with per-second billing). Cloud Dataproc also easily integrates with other Google Cloud Platform (GCP) services, giving you a powerful and complete platform for data processing, analytics and machine learning.
