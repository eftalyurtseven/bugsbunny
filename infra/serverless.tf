
# Container repository which should was created when prebuild step
data "aws_ecr_repository" "ecr-serverless" {
  name = var.ECR_LAMBDA_REPO_NAME
}

# Lambda function that working with an ecr image
resource "aws_lambda_function" "csv-importer-serverless" {
  function_name = var.LAMBDA_FUNC_NAME
  role          = aws_iam_role.iam_for_lambda.arn
  # timeout for 
  timeout = 30
  # 
  image_uri = "${data.aws_ecr_repository.ecr-serverless.repository_url}:latest"
  # Specify that lambda will be use container image
  package_type = "Image"
  description  = var.LAMBDA_DESC
  # Environment variables for lambda service.These variables will be inject to container.
  environment {
    variables = {
      S3_KEY_ID      = "${var.ACCESS_KEY_ID}"
      S3_ACCESS_KEY  = "${var.ACCESS_KEY_SECRET}"
      S3_REGION_NAME = "${var.REGION}"
      S3_BUCKET_NAME = "${aws_s3_bucket.bucket.bucket}"
      PSQL_USER      = "${aws_db_instance.default.username}"
      PSQL_PASS      = "${aws_db_instance.default.password}"
      PSQL_HOST      = "${aws_db_instance.default.address}"
      PSQL_DB        = "${aws_db_instance.default.name}"
      PSQL_PORT      = "${aws_db_instance.default.port}"
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
  ]
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "lambda-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
               "Service": "lambda.amazonaws.com"
           },
           "Effect": "Allow"
       }
   ]
}
 EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
# It creates mysql database for writing csv file to database.It is publicly accesible in the sake of simplicity.
resource "aws_db_instance" "default" {
  allocated_storage   = 10
  engine              = "postgres"
  identifier          = "csv-db"
  engine_version      = "13"
  instance_class      = "db.t3.medium"
  name                = var.DATABASE_NAME
  username            = var.DATABASE_USER
  password            = var.DATABASE_PASSWORD
  skip_final_snapshot = true
  publicly_accessible = true

}

# S3 bucket for  uploading csv files
resource "aws_s3_bucket" "bucket" {
  bucket = var.BUCKET_NAME
  acl    = "public-read"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:s3:::${var.BUCKET_NAME}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  block_public_policy = true
}

# Trigger lambda when object created
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv-importer-serverless.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

# Give allow access between s3 and lambda functions
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv-importer-serverless.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
