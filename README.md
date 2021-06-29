### Timeplan
* Needs analysis: 30min
* AWS network resource deployment: 1h30
* AWS RDS deployment: 2h (first run with Aurora Postgresql, second run with RDS PostreSQL - as PG13 not yet supported by Aurora)
* ECS task definition, service and Fargate cluster: 4h - I was stuck because of not functional docker image from Docker Hub...
* Docker deployment locally + docker build: 1h
* ALB: 1h
* Deployments: 2h
* Documentation and diagram: 1h
* Investigation and tests provisioning NLB and API Gateway: 4h

### Simplified infrastructure:
1 VPC:
* private subnets for VPC endpoints, RDS and ECS instances - multi AZ
* public subnet DMZ to host ALB - multi AZ

ECR repository
ECS Fargate cluster
RDS PostreSQL instance
Actually Aurora PostgreSQL 13.3 hasn't been released yet, neither PostgreSQL 13.3 is supported on RDS. RDS PostgreSQL 13.2 will be deployed for this usage.

### Improvements to be done:
Due to the few time allowed to provide a complete solution, following parts won't be implemented but can be evaluated for a more secure a scalable solution:
* API Gateway linked to ALB and to given methods
* RDS replica
* RDS autoscaling storage
* DB user management (not to use admin on app...) and parameter tuning
* Integrate SSM / SecretsManager for RDS user management
* KMS policy to allow Cloudwatch Logs and ECR encryption
* TF variable input validation
* ECS container hardening
* Route53 to provide specific domain name to API Gateway endpoint
* Secure API communication with TLS ACM certificates
* PrivateLink for private communication to API Gateway

### Troubleshooting
Docker image provided in Docker Hub is built for ARM64 arch, can't be run on ECS. Must be rebuilt for amd64 arch.
```
$ docker run -p 8080:8080 eldertech/infrastructure-test:latest
WARNING: The requested image's platform (linux/arm64) does not match the detected host platform (linux/amd64) and no specific platform was requested
standard_init_linux.go:228: exec user process caused: exec format error
```

### Installation notes
Working version using ALB is in branch *master*. Non-working version using NLB and API Gateway is in branch *NLB*.

Apply terraform plan:
```
terraform init
terraform workspace create new
terraform apply
```

All commands to be used are then provided as TF outputs.

Build docker image and push it to AWS ECR repository
```
docker built -t infra-test infrastructure-tech-test
docker tag infra-test:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/infra-test:latest

aws ecr get-login-password --profile $AWS_PROFILE --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/infra-test
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/infra-test:latest
```

Test and enjoy:
```
curl --request POST \
  ---url http://$ALB_DNS_NAME:$PORT/ \
  --header 'Content-Type: application/json' \
  --data '{
	"name": "Tester",
	"age": 35
}'

curl http://$ALB_DNS_NAME:$PORT/
```
