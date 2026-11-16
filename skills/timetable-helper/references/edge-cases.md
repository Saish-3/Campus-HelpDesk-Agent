# Edge Cases

- **Missing batch:** Ask the student which batch they are in; do not guess.
- **Invalid day:** The lookup accepts Monday through Sunday (case-insensitive). For any other day value, ask the student to provide a valid day.
- **Weekends:** Saturday and Sunday are valid day inputs, but this timetable has no weekend classes; report no class found for the requested batch/day.
- **No classes that day:** If the lookup returns no row for a batch and day, report that no class was found for that batch/day.
- **Ambiguous batch name (for example, `A`):** Ask which full batch name they mean, such as `CSE-A` or `ECE-A`; do not select one.
- **Missing day:** Ask the student which day they mean; do not assume today or another day.
- **Holiday:** The CSV does not identify holidays. Do not infer holiday status; report only the timetable lookup result.
