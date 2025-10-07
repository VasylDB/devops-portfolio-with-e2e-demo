import argparse
import os
import time
import boto3
from python.common.notify import slack_notify

# Create snapshots of EBS volumes that have a specific tag key=value.
# Example:
#   python python/aws/snapshot_ebs.py --tag Project=Portfolio --region eu-central-1

def parse_tag(tag: str):
    if "=" not in tag:
        raise ValueError("Tag must be Key=Value")
    k, v = tag.split("=", 1)
    return k.strip(), v.strip()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", required=True, help="Key=Value to select volumes")
    ap.add_argument("--region", default=os.getenv("AWS_REGION", "eu-central-1"))
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    key, val = parse_tag(args.tag)
    ec2 = boto3.client("ec2", region_name=args.region)

    filters = [{"Name": f"tag:{key}", "Values": [val]}]
    vols = ec2.describe_volumes(Filters=filters)["Volumes"]

    created = []
    for v in vols:
        vol_id = v["VolumeId"]
        desc = f"Portfolio snapshot of {vol_id} at {time.strftime('%Y-%m-%d %H:%M:%S')}"
        if args.dry_run:
            print(f"[DRY] Would snapshot {vol_id}")
            continue
        snap = ec2.create_snapshot(VolumeId=vol_id, Description=desc)
        snap_id = snap["SnapshotId"]
        # Basic tags for housekeeping
        ec2.create_tags(Resources=[snap_id], Tags=[
            {"Key": key, "Value": val},
            {"Key": "Project", "Value": "Portfolio"},
            {"Key": "Component", "Value": "AutomationScripts"},
        ])
        print(f"[OK] Snapshot created: {snap_id} for {vol_id}")
        created.append(snap_id)

    if created:
        slack_notify(f"EBS snapshots created: {', '.join(created)}")

if __name__ == "__main__":
    main()
