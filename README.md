# Overview

The folder contains the necessary code for the Serverless Lambda Consul tutorial.

To get started:

## Prerequisites

!> **NOTE**: The deployment of the terraform project in this section takes up to 30 minutes to complete.


- [`aws-cli +2.4.15`](https://github.com/aws/aws-cli/releases/tag/2.4.15)
- [`openssl +3.0.1`](https://github.com/openssl/openssl/releases/tag/openssl-3.0.1)
- [`kubectl +v1.22.4`](https://kubernetes.io/docs/tasks/tools/)
- [`terraform +1.0.11`](https://github.com/hashicorp/terraform/releases/tag/v1.0.6)
- [`tar (GNU tar) +1.26`](https://www.gnu.org/software/tar/) (Required for`kubectl cp`)
- If using Windows as your local environment's operating system, review this [StackOverflow thread on using `kubectl cp` to/from Windows environments](https://stackoverflow.com/questions/47782819/copying-files-to-from-windows-container-on-a-k8s-cluster).
- [`git +v2.30.1`](https://github.com/git-guides/install-git)


    
Navigate into the project's terraform folder for this tutorial.

  ```shell
  $ cd datacenter-deploy-eks-lambda-hcp/terraform
  ```

Set the HCP service principal credentials as environment variables on your local workstation.

  ```shell
  $ export HCP_CLIENT_ID=YOUR_HCP_CLIENT_ID_GOES_HERE
  ```

  ```shell
  $ export HCP_CLIENT_SECRET=YOUR_HCP_CLIENT_SECRET_GOES_HEREt q
  ```
Initialize and deploy the terraform project

  ```shell
  $ terraform init && terraform apply -auto-approve
  ```
