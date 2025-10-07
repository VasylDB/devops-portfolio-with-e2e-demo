import argparse
import datetime as dt
import sys
import boto3

# Report IAM access keys older than N days or unused in the last M days.
# Safe, read-only audit to help you rotate keys.

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--old-days", type=int, default=90, help="Flag keys older than this many days")
    ap.add_argument("--unused-days", type=int, default=60, help="Flag keys not used for this many days")
    args = ap.parse_args()

    iam = boto3.client("iam")
    sts = boto3.client("sts")
    account = sts.get_caller_identity()["Account"]

    now = dt.datetime.utcnow().replace(tzinfo=dt.timezone.utc)
    old_cut = now - dt.timedelta(days=args.old_days)
    unused_cut = now - dt.timedelta(days=args.unused_days)

    paginator = iam.get_paginator("list_users")
    flagged = []
    for page in paginator.paginate():
        for user in page["Users"]:
            uname = user["UserName"]
            keys = iam.list_access_keys(UserName=uname)["AccessKeyMetadata"]
            for k in keys:
                kid = k["AccessKeyId"]
                created = k["CreateDate"]
                last_used_resp = iam.get_access_key_last_used(AccessKeyId=kid)
                last_used = last_used_resp.get("AccessKeyLastUsed", {}).get("LastUsedDate")

                too_old = created < old_cut
                too_unused = (last_used is None) or (last_used < unused_cut)

                if too_old or too_unused:
                    flagged.append({
                        "user": uname,
                        "access_key_id": kid,
                        "created": created.isoformat(),
                        "last_used": last_used.isoformat() if last_used else "never",
                        "too_old": bool(too_old),
                        "too_unused": bool(too_unused),
                    })

    print(f"Account: {account}")
    if not flagged:
        print("No keys need attention.")
        sys.exit(0)

    print("Keys to review:")
    for f in flagged:
        print(f"- {f['user']} / {f['access_key_id']} | created={f['created']} | last_used={f['last_used']} | old={f['too_old']} | unused={f['too_unused']}")
    sys.exit(1)

if __name__ == "__main__":
    main()
