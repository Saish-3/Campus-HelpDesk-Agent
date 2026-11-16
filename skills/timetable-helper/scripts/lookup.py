#!/usr/bin/env python3
"""Look up timetable rows for a batch and day."""

import csv
import sys
from pathlib import Path


EXPECTED_COLUMNS = (
    "batch",
    "day",
    "start_time",
    "end_time",
    "subject",
    "room",
    "faculty",
)
DAYS = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
}


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: python lookup.py <batch> <day>", file=sys.stderr)
        return 2

    batch, day = (argument.strip() for argument in sys.argv[1:])
    if not batch:
        print("Error: batch must not be empty.", file=sys.stderr)
        return 2
    if day.casefold() not in DAYS:
        print(
            "Error: day must be a weekday name from Monday through Sunday.",
            file=sys.stderr,
        )
        return 2

    csv_path = Path(__file__).resolve().parents[3] / "data" / "timetable.csv"
    if not csv_path.is_file():
        print(f"Error: timetable CSV not found: {csv_path}", file=sys.stderr)
        return 1

    try:
        with csv_path.open(newline="", encoding="utf-8") as timetable_file:
            reader = csv.DictReader(timetable_file)
            if reader.fieldnames != list(EXPECTED_COLUMNS):
                print(
                    "Error: timetable CSV has missing or unexpected columns.",
                    file=sys.stderr,
                )
                return 1

            matches = [
                row
                for row in reader
                if row["batch"].strip().casefold() == batch.casefold()
                and row["day"].strip().casefold() == day.casefold()
            ]
    except (OSError, csv.Error) as error:
        print(f"Error: could not read timetable CSV: {error}", file=sys.stderr)
        return 1

    if not matches:
        print("NO_MATCH")
        return 0

    writer = csv.writer(sys.stdout, lineterminator="\n")
    writer.writerow(EXPECTED_COLUMNS)
    for row in matches:
        writer.writerow(row[column] for column in EXPECTED_COLUMNS)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
