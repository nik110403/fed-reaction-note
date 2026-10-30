# Provenance

- `captured-environment.lock`: renv-format lockfile, byte-identical to the file whose sha256 is in `session_info.txt` (28 packages, none missing), captured 2026-09-11 from the user library.
- `session_info.txt`: capture facts (R version, counts, loader file, source-lock sha256).
- Label: **later-captured plausible superset; not the producing environment and not evidence that published results reproduce**.
- It is not a project `renv.lock`; do not restore from it as if it were the original environment.
