# Resume

This project is a Typst-based resume, based on an early version of [imprecv](https://github.com/jskherman/imprecv). It uses a Meson build system and custom post-processing to overcome Typst's current limitations regarding native PDF attachment linking.

## Requirements

The following CLI tools are required to build the project (tested versions in parentheses):

- **Typst** (>= 0.14.2): The core typesetting engine.
- **Meson** (>= 1.11.1): The build configuration system.
- **Ninja** (>= 1.13.2): The backend build executor.
- **qpdf** (>= 12.3.2): Used for PDF structural transformations.
- **jq** (>= 1.8.1): Used for JSON-based PDF link patching.
- **pandoc** (optional): Converts the generated HTML into GitHub-Flavored Markdown.

### Fonts
The following font families must be installed for correct rendering:
- **Inter**: Used for the main body.
- **IBM Plex Serif**: Used for headings.
- **IBM Plex Mono**: Used for the footer/end note.

## Building

To generate the resume artifacts, use the following commands:

```bash
# Initialize the build directory
meson setup build

# Optional: Configure build options (e.g., PDF standard, YAML embedding)
# Use 'meson configure build' to see all current settings
meson configure build -Dpdf_standard=2.0 -Dembed_yml=true

# Compile all targets (PDF + HTML + Markdown)
meson compile -C build
```

The final outputs will be located at:
*   `build/resume.pdf` (Patched PDF with optional attachment)
*   `build/resume.html` (Experimental HTML version)
*   `build/resume.md` (GitHub-Flavored Markdown generated via Pandoc, if installed)

## Build Options

- **`pdf_standard`**: The PDF standard to enforce conformance with (e.g., `1.7`, `a-2b`, `ua-1`). Default is `none`.
- **`embed_yml`**: Boolean. If `true` (default), embeds the `resume.yml` source file into the PDF and enables the clickable attachment link in the footer. If `false`, generates a standard PDF and omits the attachment logic.

## Build Process & Targets

The build system performs the following steps:

1.  **`typst_compile`**: Compiles `resume.typ` into a PDF. If `embed_yml` is enabled, it produces an intermediate `resume_raw.pdf` with the embedded file.
2.  **`patch_pdf_links`**: (Only if `embed_yml=true`) Post-processes the PDF using `qpdf` and `jq` to convert the `attach:resume.yaml` placeholder link into a native PDF **Go-To-Embedded** action.
3.  **`resume_html`**: Generates an experimental HTML version of the resume using Typst's development features.
4.  **`resume_markdown`**: (Only if `pandoc` is found) Converts `resume.html` into GitHub-Flavored Markdown (`resume.md`).

### Why Patching?
Typst currently lacks native support for links that trigger the opening of embedded attachments (see [Typst Issue #6200](https://github.com/typst/typst/issues/6200)). This project circumvents that by using a custom protocol (`attach:`) which is then transformed into a native PDF **Go-To-Embedded** action during the build phase.

## Continuous Integration

This project includes a **GitHub Action** (`.github/workflows/build.yml`) that automatically:
1.  Installs all required dependencies and the latest Typst compiler.
2.  Builds the PDF, HTML and Markdown versions of the resume.
3.  Uploads the results as artifacts, renamed to include the current date.
