---
name: timetable-helper
description: Looks up a student's university class timetable by batch and day. Trigger when a student asks about a class, subject, time, room, or faculty for a particular batch and day.
---

# Timetable Helper

Before answering a timetable question, run `python scripts/lookup.py <batch> <day>` from this Skill's directory or read `../../data/timetable.csv`.

Answers must come ONLY from rows returned by the lookup. If no row matches, reply that no class was found for that batch/day. NEVER invent a subject, room, time, or faculty.

If the batch or day is missing, ask the student for it before looking up the timetable. For column meanings, see [the column dictionary](references/columns.md); for input and schedule edge cases, see [edge cases](references/edge-cases.md).
