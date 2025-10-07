import argparse
import os
import boto3
from botocore.exceptions import ClientError
from python.common.notify import slack_notify

# Minimal local->S3 sync. For large data use aws s3 sync (faster, parallelized).

def upload_file(s3, bucket, key, path):
    s3.upload_file(path, bucket, key, ExtraArgs={"ServerSideEncryption": "AES256"})

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("src_dir")
    ap.add_argument("bucket")
    ap.add_argument("--prefix", default="")
    ap.add_argument("--region", default=os.getenv("AWS_REGION", "eu-central-1"))
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    s3 = boto3.client("s3", region_name=args.region)

    uploaded = 0
    for root, _, files in os.walk(args.src_dir):
        for f in files:
            local_path = os.path.join(root, f)
            rel = os.path.relpath(local_path, args.src_dir).replace("\\", "/")
            key = f"{args.prefix}/{rel}" if args.prefix else rel
            if args.dry_run:
                print(f"[DRY] Would upload {local_path} -> s3://{args.bucket}/{key}")
            else:
                try:
                    upload_file(s3, args.bucket, key, local_path)
                    print(f"[OK] {local_path} -> s3://{args.bucket}/{key}")
                    uploaded += 1
                except ClientError as e:
                    print(f"[ERR] {local_path}: {e}")

    if uploaded:
        slack_notify(f"S3 sync complete. Uploaded files: {uploaded}")

if __name__ == "__main__":
    main()
