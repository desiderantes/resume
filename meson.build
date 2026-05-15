project('resume', version: '0.1.0')

typst = find_program('typst', required: true)
qpdf = find_program('qpdf', required: true)
jq = find_program('jq', required: true)

# Explicitly define the entrypoint and output
main_typ = 'resume.typ'
raw_pdf = 'resume_raw.pdf'
final_pdf = 'resume.pdf'

# All project files that should trigger a rebuild when changed
project_sources = ['cv.typ', 'utils.typ', 'resume.yml']

# Step 1: Compile the raw PDF with Typst
typst_args = [typst, 'compile', '--features', 'html', '@INPUT@', '@OUTPUT@']
pdf_standard = get_option('pdf_standard')
if pdf_standard != 'none'
    typst_args += ['--pdf-standard', pdf_standard]
endif

typst_target = custom_target(
    'typst_compile',
    input: main_typ,
    output: raw_pdf,
    command: typst_args,
    depend_files: project_sources,
)

# Step 2: Patch the PDF to link the "attach:resume.yaml" URI to a GoToE action using jq
# We use a carefully escaped jq filter to perform the transformation.
jq_filter = 'walk(if type=="object" and ."/URI"=="u:attach:resume.yaml" then {"/S":"/GoToE","/T":{"/R":"/C","/N":"u:resume.yml"}} else . end)'

patch_target = custom_target(
    'patch_pdf_links',
    input: typst_target,
    output: final_pdf,
    command: [
        'sh',
        '-c', '@0@ --json-output @INPUT@ tmp.json && @1@ \'@2@\' tmp.json > patched.json && @0@ --json-input patched.json @OUTPUT@'.format(qpdf.full_path(), jq.full_path(), jq_filter),
    ],
    build_by_default: true,
    install: true,
    install_dir: get_option('datadir') / 'resume',
)

# Step 3: Compile to HTML (experimental)
custom_target(
    'resume_html',
    input: main_typ,
    output: 'resume.html',
    command: [
        typst,
        'compile',
        '--features', 'html',
        '--input', 'format=html',
        '@INPUT@',
        '@OUTPUT@',
    ],
    depend_files: project_sources,
    build_by_default: true,
    install: true,
    install_dir: get_option('datadir') / 'resume',
)
