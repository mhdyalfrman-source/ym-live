# Maintaining the CodeCanyon reference

These HTML fragments are the editable sources for eleven supplemental guides. The API contracts and page wrapper are in `tools/build_review_documentation.py`. That script reads the existing buyer package controllers, generates twelve offline HTML guides and an API JSON catalogue, updates the backend documentation pointer, and saves the static verification report.

From the project root, with Python 3.10+:

```text
python tools/build_review_documentation.py
python tools/verify_review_documentation.py
```

The validator is read-only and writes its JSON result to stdout. The builder saves that result under CodeCanyon_Package/Reviewer_Information. No extra Python packages are required.

The installation index, documentation README, CSS and JavaScript remain directly editable in Main_File/documentation. Update fragments first, then regenerate their output. Keep source examples synchronized with the delivered buyer code; route coverage checks do not prove payload semantics.

Actual captures belong in documentation/assets/screenshots. Add figures/captions in visual-walkthroughs.html only after obtaining real images; update the pending status in the validation script and reviewer report when the missing evidence actually exists. Do not fabricate screens or relabel promotional images as actual captures.

Do not run prepare_codecanyon_package.ps1 to regenerate documentation: it replaces the complete buyer directory from a different development tree. This builder documents the delivered GamePix integration without modifying application code, deploying, or replacing the distribution ZIP.
