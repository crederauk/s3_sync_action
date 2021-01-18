#!/bin/bash

set -e

REQUIRED_ENVS="SOURCE_DIRECTORY S3_BUCKET AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY"

function check_for_required_env_vars() {
    for ENV in $REQUIRED_ENVS; do 
        if [[ -z "${!ENV}" ]]; then 
            echo "Error: Environment variable: \"${ENV}\" not provided." 
            Exit 1 
        fi
    done
}

function aws_configure() {
    export AWS_ACCESS_KEY_ID=$INPUT_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$INPUT_SECRET_ACCESS_KEY
    export AWS_DEFAULT_REGION=$INPUT_REGION
}

function assume_role() {
    if [[ ! -z ${ASSUME_ROLE} ]]; then 
        echo "Assuming Role: ${ASSUME_ROLE}"
        ROLE="arn:aws:iam::${ACC_ID}:role/${ASSUME_ROLE}"
        CREDENTIALS=$(aws sts assume-role --role-arn ${ROLE} --role-session-name ecrpush --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)
        read id key token <<< ${CREDENTIALS}
        export AWS_ACCESS_KEY_ID="${id}"
        export AWS_SECRET_ACCESS_KEY="${key}"
        export AWS_SESSION_TOKEN="${token}"
        echo "Role: ${INPUT_ASSUME_ROLE} assumed"
    else 
        echo "No \"ASSUME_ROLE\" variable passed in - using credintials for role instead"
    fi
}

function sync(){
    sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
        --no-progress \
        ${ENDPOINT} $*"
}

function unset_aws(){
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
}

function main(){
    check_for_required_env_vars

    if [[ -z "$AWS_REGION" ]]; then
        echo "Environment variable: \"AWS_REGION\" not provided, defaulting to us-east-1"
        AWS_REGION="us-east-1"
    fi

    if [[ -z "$S3_PATH" ]]; then
        echo "Environment variable: \"S3_PATH\" not provided, syncing to root S3 Directory"
    fi

    if [[ ! -z "$AWS_S3_ENDPOINT" ]]; then
        ENDPOINT="--endpoint-url $AWS_S3_ENDPOINT"
    fi

    if [[ -z "$ACCOUNT_ID" ]]; then
        echo "Environment variable: \"ACCOUNT_ID\" not provided, using STS to retrieve it" 
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    fi

    aws_configure
    assume_role
    sync
    unset_aws
}

main
