# Infrastructure
It provides code infrastructure for the creation, connections, and communication of AWS resources and uses **Terraform**.
It prepares the cloud environment required by the other 2 applications (container & serverless).
To run these applications you should follow the instructions in this repo. 

## Technology
- AWS CLI (aws-cli/2.1.28)
- Terraform (v1.1.4)


| :warning: Please ensure to access aws with `aws configure`! |
| ----------------------------------------------------------- |

| :warning: Please ensure to access aws with `aws ecr login`! |
| ----------------------------------------------------------- |



## Build and Apply
1. Create necessary services for applications.
  ```sh
  sudo chmod +x ./prebuild.sh && ./prebuild.sh
  ````
  Cool, we are ready to continue with main services.

2. Push to ECR repos the applications 
  ```sh
  sudo chmod +x ./orchestrator.sh && ./orchestrator.sh
  ````
2. Initalize terraform application 
  ```sh
  terraform init
  ````
3. Apply the configuration
  ```sh
  terraform apply --auto-approve
  ````
4. Enter the required variables [AWS-ACCESS-KEY, AWS-KEY-SECRET]
5. Wow, you can really dance now! :) 


## Destroy
If you want to destroy all environments you can run these commands:
```sh
  cd prebuild && terraform destroy && cd .. && terraform destroy
```

If you have any questions or feedback, please feel free to share them with us on email or github issues!

