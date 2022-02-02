cd prebuild && 
export FACTORIAL_REPO_URL=$(terraform output -raw factorial_repository_url) && 
export LAMBDA_REPO_URL=$(terraform output -raw lambda_repository_url) && 
cd .. &&
cd ../container && docker build . -t $FACTORIAL_REPO_URL && docker push $FACTORIAL_REPO_URL &&
cd ../serverless && docker build . -t $LAMBDA_REPO_URL && docker push $LAMBDA_REPO_URL && cd ../infra