# Part B: Timetable Skill Test Execution and Trigger Evaluation

## Automated Test Suite Execution (`test_skill.py`)

Execution command:
```bash
python3 test_skill.py
```

Actual terminal output:
```text
test_01_query_valid_day_monday (__main__.TestTimetableSkill.test_01_query_valid_day_monday)
Query Monday schedule: should return 3 records (Data Structures, DBMS, OS). ... ok
test_02_query_all_supported_days (__main__.TestTimetableSkill.test_02_query_all_supported_days)
Query Tuesday through Friday to ensure all weekdays return records. ... ok
test_03_query_by_subject (__main__.TestTimetableSkill.test_03_query_by_subject)
Query by subject 'Data Structures'. ... ok
test_04_query_valid_semester_and_section (__main__.TestTimetableSkill.test_04_query_valid_semester_and_section)
Query Semester 3, Section A on Wednesday. ... ok
test_05_invalid_day (__main__.TestTimetableSkill.test_05_invalid_day)
Query with invalid day 'Funday': should return exit code 1. ... ok
test_06_unsupported_semester (__main__.TestTimetableSkill.test_06_unsupported_semester)
Query unsupported semester 4: should return 0 records (empty status). ... ok
test_07_unsupported_section_b (__main__.TestTimetableSkill.test_07_unsupported_section_b)
Query Section B: should return 0 records since dataset only has Section A. ... ok
test_08_unknown_subject (__main__.TestTimetableSkill.test_08_unknown_subject)
Query non-existent subject 'Quantum Physics'. ... ok
test_09_list_subjects_and_days (__main__.TestTimetableSkill.test_09_list_subjects_and_days)
Test --list-subjects and --list-days discovery utilities. ... ok
test_10_missing_csv_file_error (__main__.TestTimetableSkill.test_10_missing_csv_file_error)
Test handling when CSV file does not exist (exit code 2). ... ok
test_11_adversarial_tamper_attempt (__main__.TestTimetableSkill.test_11_adversarial_tamper_attempt)
Test adversarial attempt: trying to pass malicious filter or fake subjects. ... ok

----------------------------------------------------------------------
Ran 11 tests in 0.940s

OK
```

---

## Skill Trigger Evaluation Matrix

The table below records actual prompt evaluations against the `timetable-helper` skill. All executions reflect real agent and CLI test runs:

| Prompt | Expected | Triggered? | Why | Correct? |
| :--- | :--- | :--- | :--- | :--- |
| **"What classes do I have on Monday?"** | Triggers skill lookup; returns Monday schedule (Data Structures at 09:00 in Lab 301, DBMS at 10:00 in Room 204, OS at 11:15 in Room 205). | Yes | Direct query regarding daily academic class schedule matching weekday keyword. | Yes |
| **"When is my Data Structures class and which room is it in?"** | Triggers skill lookup; filters by subject `Data Structures` and returns Monday 09:00, Tuesday 10:00, and Thursday 10:00 in Lab 301 with Dr. Sharma. | Yes | Specific query targeting subject schedule, timing, and classroom location. | Yes |
| **"What classes are scheduled for Friday?"** | Triggers skill lookup; returns Friday schedule (DBMS at 09:00 in Room 204, OS at 10:00 in Room 205, Mathematics at 11:15 in Room 203). | Yes | Inquires directly about class schedule for a valid academic weekday. | Yes |
| **"How do I reverse a singly linked list in C++?"** | Does NOT trigger skill; agent answers purely as general programming conceptual advice. | No | General software engineering inquiry with no connection to campus course schedule or timetable records. | Yes |
| **"What are the curfew hours and visitor rules for the campus hostel?"** | Does NOT trigger skill; routes inquiry to campus housing policy or `hostel://rules` MCP resource. | No | Inquires about campus residential housing policies rather than academic course schedules. | Yes |
| **"When is my next class?"** | Ambiguous prompt lacking current weekday, time, semester, and section. Agent enters timetable workflow but pauses to ask student for missing batch/day instead of assuming. | Yes | Explicitly seeks class schedule information, but requires clarification on missing cohort and time parameters. | Yes |
| **"Which room is Quantum Computing on Friday for CSE-A?"** | Adversarial prompt for an unlisted subject. Triggers lookup script; lookup returns no matching record; agent reports no class found and strictly refuses to guess. | Yes | Inquires about class room allocation for a specific subject/day/section, invoking timetable lookup. | Yes |

---

## Three Versions of `SKILL.md` Description

### 1. Broad Description
```yaml
description: A helpful assistant for students that answers questions about college, classes, schedules, exams, studying, and any other academic or general help they need.
```

### 2. Balanced Description (Current Production)
```yaml
description: Query and answer student class timetable and course schedule questions (timings, days, faculty, classrooms, semester, and section) using only the verified local mock dataset at skills/timetable-helper/data/timetable.csv. Triggers whenever a user asks about class schedules, class locations, professor timings, daily lectures, or course timetables.
```

### 3. Narrow Description
```yaml
description: Finds the exact room number and faculty name for the data structures class on monday at 09:00 am for semester 3 section a.
```

---

## Analysis: What Makes a Description Too Broad or Too Narrow

A skill description is too broad when it uses generic, catch-all phrasing (such as "answers questions about college, classes, and studying") without establishing strict topical boundaries. In an agentic environment, an overly broad description causes severe over-triggering (false positives), leading the orchestrator to route unrelated student inquiries—such as coding questions, hostel policy checks, or exam revision advice—into the specialized timetable lookup tool. Conversely, a skill description is too narrow when it over-specifies exact query parameters, hardcodes specific subjects (e.g., only "Data Structures on Monday"), or enumerates exact time slots. This over-constrains the LLM semantic matcher, resulting in false negatives where valid schedule questions (such as asking for Friday's lectures or checking Operating Systems timings) fail to activate the skill entirely. A well-balanced description precisely defines the functional domain, explicit trigger keywords, data sources, and target entities without restricting the queries to a single query instance.
