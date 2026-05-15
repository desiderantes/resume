# Resume

This project is a Typst-based resume, based on an early version of [imprecv](https://github.com/jskherman/imprecv). It uses a Meson build system and custom post-processing to overcome Typst's current limitations regarding native PDF attachment linking.

## Requirements

The following CLI tools are required to build the project (tested versions in parentheses):

- **Typst** (>= 0.14.2): The core typesetting engine.
- **Meson** (>= 1.11.1): The build configuration system.
- **Ninja** (>= 1.13.2): The backend build executor.
- **qpdf** (>= 12.3.2): Used for PDF structural transformations.
- **jq** (>= 1.8.1): Used for JSON-based PDF link patching.

## Building

To generate the final PDF, use the following commands:

```bash
# Initialize the build directory
meson setup build

# Optional: Configure the PDF standard (e.g., a-2b, 1.7)
# Use 'meson configure build' to see all options
meson configure build -Dpdf_standard=1.7

# Compile and patch the PDF
meson compile -C build
```

The final output will be located at `build/resume.pdf` and `build/resume.html`.

## Build Options

- **`pdf_standard`**: The PDF standard to enforce conformance with (e.g., `1.7`, `a-2b`, `ua-1`). Default is `none`.

## Build Process & Targets

The build system performs a two-step process:

1.  **`typst_compile`**: Compiles `resume.typ` into a raw PDF and embeds the `resume.yml` data.
2.  **`patch_pdf_links`**: (Default Target) Post-processes the PDF using `qpdf` and `jq` to convert the `attach:resume.yaml` placeholder link into a native PDF **Go-To-Embedded** action.
3.  **`resume_html`**: Generates an experimental HTML version of the resume using Typst's development features.

### Why Patching?
Typst currently lacks native support for links that trigger the opening of embedded attachments (see [Typst Issue #6200](https://github.com/typst/typst/issues/6200)). This project circumvents that by using a custom protocol (`attach:`) which is then transformed into a native PDF **Go-To-Embedded** action during the build phase.


## Installation

To install the resume to your system's data directory:

```bash
meson install -C build
```
