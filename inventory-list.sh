#!/bin/bash

account_id=$(aws sts get-caller-identity --query "Account" --output text)
account_alias=$(aws iam list-account-aliases --output text | awk {'print $2'})

echo "####### CodeCommit - $account_alias - $account_id #######"
aws ec2 describe-regions --query "Regions[].RegionName" --output text | tr '\t' '\n' | while read region; do
  aws codecommit list-repositories --region $region --query "repositories[].repositoryName" --output text | tr '\t' '\n' | while read repo; do
    echo "arn:aws:codecommit:$region:$account_id:$repo"
  done
done

echo "####### CodePipeline - $account_alias - $account_id #######"
aws ec2 describe-regions --query "Regions[].RegionName" --output text | tr '\t' '\n' | while read region; do
  aws codecommit list-repositories --region $region --query "repositories[].repositoryName" --output text | tr '\t' '\n' | while read repo; do
    echo "arn:aws:codecommit:$region:$account_id:$repo"
  done
done

aws ec2 describe-regions --query "Regions[].RegionName" --output text | tr '\t' '\n' | while read region; do
    pipelines=$(aws codepipeline list-pipelines --region $region --query "pipelines[].name" --output text)

    if [ -n "$pipelines" ]; then
        for pipeline in $pipelines; do
            echo "$region - $pipeline"
            aws codepipeline get-pipeline --name codepipeline-riskpack-batch-api-master --query "pipeline.stages[?name=='Source']" --output json --no-cli-pager
            echo -e "\n"
        done
    fi
done
