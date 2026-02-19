#!/usr/bin/env python3
import json
import os
import subprocess
import sys


def sh(cmd):
    subprocess.check_call(cmd)


def sh_out(cmd):
    return subprocess.check_output(cmd).decode("utf-8")


def main():
    if len(sys.argv) != 2:
        print("Usage: apply_connect_overrides.py <overrides.json>", file=sys.stderr)
        sys.exit(2)

    overrides_path = sys.argv[1]

    region = os.environ.get("AWS_REGION", "eu-west-2")
    instance_id = os.environ.get("INSTANCE_ID")
    hoo_id = os.environ.get("HOO_ID")

    if not instance_id or not hoo_id:
        print("ERROR: INSTANCE_ID and HOO_ID env vars are required.", file=sys.stderr)
        sys.exit(2)

    overrides = json.load(open(overrides_path, "r", encoding="utf-8"))
    if not overrides:
        print("No overrides provided. Nothing to do.")
        return

    # Map existing overrides by name -> overrideId
    existing_raw = sh_out([
        "aws", "connect", "list-hours-of-operation-overrides",
        "--region", region,
        "--instance-id", instance_id,
        "--hours-of-operation-id", hoo_id
    ])
    existing = json.loads(existing_raw).get("HoursOfOperationOverrideSummaryList", [])
    by_name = {x["Name"]: x["HoursOfOperationOverrideId"] for x in existing}

    for name, ov in overrides.items():
        desc = ov.get("description")
        eff_from = ov["effective_from"]
        eff_till = ov["effective_till"]
        otype = ov["override_type"].upper()

        # Connect API expects config blocks
        cfg = []
        for c in ov["override_config"]:
            cfg.append({
                "Day": c["day"],
                "StartTime": {"Hours": c["start_hours"], "Minutes": c["start_minutes"]},
                "EndTime": {"Hours": c["end_hours"], "Minutes": c["end_minutes"]},
            })

        # Optional recurrence
        rec = ov.get("recurrence")
        rec_arg = None
        if rec:
            pattern = {
                "Frequency": rec["frequency"].upper(),
                "Interval": rec.get("interval", 1),
            }
            if rec.get("by_month") is not None:
                pattern["ByMonth"] = rec["by_month"]
            if rec.get("by_month_day") is not None:
                pattern["ByMonthDay"] = rec["by_month_day"]
            if rec.get("by_weekday_occurrence") is not None:
                pattern["ByWeekdayOccurrence"] = rec["by_weekday_occurrence"]
            rec_arg = json.dumps({"RecurrencePattern": pattern})

        if name in by_name:
            oid = by_name[name]
            cmd = [
                "aws", "connect", "update-hours-of-operation-override",
                "--region", region,
                "--instance-id", instance_id,
                "--hours-of-operation-id", hoo_id,
                "--hours-of-operation-override-id", oid,
                "--name", name,
                "--effective-from", eff_from,
                "--effective-till", eff_till,
                "--override-type", otype,
                "--config", json.dumps(cfg),
            ]
            if desc:
                cmd += ["--description", desc]
            if rec_arg:
                cmd += ["--recurrence-config", rec_arg]

            sh(cmd)
            print(f"Updated override: {name}")
        else:
            cmd = [
                "aws", "connect", "create-hours-of-operation-override",
                "--region", region,
                "--instance-id", instance_id,
                "--hours-of-operation-id", hoo_id,
                "--name", name,
                "--effective-from", eff_from,
                "--effective-till", eff_till,
                "--override-type", otype,
                "--config", json.dumps(cfg),
            ]
            if desc:
                cmd += ["--description", desc]
            if rec_arg:
                cmd += ["--recurrence-config", rec_arg]

            sh(cmd)
            print(f"Created override: {name}")


if __name__ == "__main__":
    main()
