import argparse
import sys
import time
from kubernetes import client, config, watch
from python.common.notify import slack_notify

# Watch a Deployment rollout until complete or timeout.

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("namespace")
    ap.add_argument("deployment")
    ap.add_argument("--timeout", type=int, default=600, help="Seconds to wait")
    args = ap.parse_args()

    config.load_kube_config()
    apps = client.AppsV1Api()

    start = time.time()
    w = watch.Watch()
    for event in w.stream(apps.list_namespaced_deployment, namespace=args.namespace, timeout_seconds=args.timeout):
        # Stop if timed out
        if time.time() - start > args.timeout:
            print("[ERR] Timeout exceeded")
            slack_notify(f"Rollout timeout: {args.namespace}/{args.deployment}")
            sys.exit(2)

        dep = event["object"]
        if dep.metadata.name != args.deployment:
            continue

        status = dep.status
        ready = (status.updated_replicas == dep.spec.replicas and
                 status.replicas == dep.spec.replicas and
                 status.available_replicas == dep.spec.replicas and
                 status.observed_generation >= dep.metadata.generation)
        if ready:
            print("[OK] Rollout complete")
            slack_notify(f"Rollout success: {args.namespace}/{args.deployment}")
            sys.exit(0)
    # If stream naturally ends, treat as timeout
    print("[ERR] Watch ended before completion")
    sys.exit(3)

if __name__ == "__main__":
    main()
