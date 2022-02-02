# Factorial Calculator

Factorial calculator is an HTTP handler that has a single endpoint for calculating the factorial value with the given input. It runs AWS ECS. For more detail please see infra/README.md.


## Technology
* Golang v.1.15

## Build
Factorial calculator is a simple golang application you can build `go build ./.. && ./main`
- You can also use **Docker** for building and running
  ```sh
    docker build -t <YOUR-IMAGE-NAME>
    docker run --rm -i -t -p 80:80 <YOUR-IMAGE-NAME>
  ```

## Test
You can run tests with default go cli. For example: 
`go test ./../`

## API
Factorial calculator uses query parameters and you should send `?number` parameter in your request.

Request
```sh
  curl "localhost/?number=5"
````

Response
```sh
  120
```

## Version Update
You can use the `latest` tag on your Docker images and push it to ECR. ECS task will be automatically deploy it 
