account_id=111122223333
region=us-east-1

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $account_id.dkr.ecr.us-east-1.amazonaws.com

