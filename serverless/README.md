# CSV Migrator to RDS (Serverless)
It is a serverless method designed to write CSV files uploaded to S3 to RDS database. AWS Lambda is configured to automatically trigger when content comes into AWS S3. You can find the table instructure under `http_logs.sql` file. And If you want to review the test csv file you can see under `http_logs.csv`



## Technology
* Golang v.1.15

## Development

* **Local Development**
  - Make sure you have "Go" installed on your environment.
  - Install the required packages and run vendor
  ```sh
  go get 
  go vendor
  ```
  - You can develop your function in `main.go`
  - You can also set environment variables
  ```sh
  export AWS_LAMBDA_RUNTIME_API=<YOUR_LAMBDA_RUNTIME_API>
  export _LAMBDA_SERVER_PORT=<YOUR_LAMBDA_SERVER_PORT>
  .
  .
  .
  ````
  - Run the script 
  `go run .` or `go build ./... && ./main`

* AWS 
  - You should build & push a new docker image to ECR. 
  ```sh
  docker build . -t <YOUR-TAG>
  docker push <YOUR-TAG> <YOUR-ECR-REPO-URL:latest>
  ```
  - After all you can change the `image` on AWS Lambda UI _(I know, It's not cool and I'll develop a codebuild pipeline here.)_

## Upload CSV
If you have a AWS permitted user. You can see the `<BUCKET_NAME>` bucket and also you can upload a csv file. For CSV Template please see the `http_logs.csv`

## Parameters
### Environment Variables
* **S3_KEY_ID**: AWS Access key ID for connecting a s3 bucket
* **S3_REGION_NAME**: Region for target s3
* **PSQL_USER**: Your RDS database username
* **PSQL_PASS**: Your users' password for connection
* **PSQL_HOST**: Your RDS endpoint
* **PSQL_PORT**: Your RDS port number
