# AWS S3 Sync Action

This Action syncs a local directory to S3 - can be used host a site from S3.

## Parameters
| Parameter |  Default | Description |
|-----------|---------|-------------|
| `SOURCE_DIRECTORY` | | The local directory to sync to S3 |
| `S3_BUCKET` | | The AWS S3 Name/ID that the directory will be synced to |
| `AWS_ACCESS_KEY_ID` | | The access key ID of the account that the github user or role is in |
| `AWS_SECRET_ACCESS_KEY` | | The secret access key of the account that the github user or role is in |
| `AWS_REGION` | `us-east-1` | Your AWS region |
| `S3_PATH` | `null` | The path to the directory in the S3 bucket that you want to sync to (if blank, will stnc to root folder) |
| `ASSUME_ROLE` | `null` | The name of the role to assume, if needed |
| `ACCOUNT_ID` | `null`* | The AWS Account ID of the role to assume - only used if ASSUME_ROLE is provided *uses STS CLI call to get current account ID if not provided |
| `AWS_S3_ENDPOINT` | `null` | The endpoint URL for the S3 to sync to |

## Additional Args

This action uses the `aws s3 sync` ([docs found here](https://docs.aws.amazon.com/cli/latest/reference/s3/sync.html)) AWS CLI call and additional flags can be passed in through the `with.args` input (as below).

## Example
```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
    - uses: dmwgroup/s3-sync@master
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        SOURCE_DIRECTORY: 'build'
        S3_BUCKET: ${{ secrets.AWS_S3_HOST_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: 'eu-west-2'
        ACCOUNT_ID: '12345678910'
        S3_PATH: 'site_files'
        ASSUME_ROLE: 's3_uploader_role'
```

## License
The MIT License (MIT)