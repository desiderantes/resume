project('resume', version: '0.1.0', meson_version: '>= 1.9.0',)

typst = find_program('typst', required: true)
qpdf = find_program('qpdf', required: true)
jq = find_program('jq', required: true)
pandoc = find_program('pandoc', required: false)

# Font verification
fclist = find_program('fc-list', required: false)
if fclist.found()
    required_fonts = ['IBM Plex Serif', 'Inter Medium', 'IBM Plex Mono']
    foreach f : required_fonts
        r = run_command(fclist, f, check: false)
        if r.returncode() != 0 or r.stdout().strip() == ''
            # We don't fail hard here because some environments might have fonts
            # in non-standard locations that fc-list misses, but we warn.
            warning(
                'Font "@0@" not found by fc-list. Rendering may be incorrect.'.format(f),
            )
        endif
    endforeach
endif

# Explicitly define the entrypoint and output
main_typ = 'resume.typ'
raw_pdf = 'resume_raw.pdf'
final_pdf = 'resume.pdf'

# All project files that should trigger a rebuild when changed
project_sources = ['cv.typ', 'utils.typ', 'resume.yml']

embed_yml = get_option('embed_yml')
embed_diploma = get_option('embed_diploma')
embed_certs = get_option('embed_certs')

# Step 1: Compile the PDF with Typst
typst_args = [typst, 'compile', '--features', 'html', '@INPUT@', '@OUTPUT@']

embed_args =  ['--input', 'embed_yml=@0@'.format(embed_yml)]
embed_args += ['--input', 'embed_diploma=@0@'.format(embed_diploma)]
embed_args += ['--input', 'embed_certs=@0@'.format(embed_certs)]
typst_args += embed_args

pdf_standard = get_option('pdf_standard')
if pdf_standard != 'none'
    typst_args += ['--pdf-standard', pdf_standard]
endif

if embed_yml
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
            '-c', '@0@ --json-output "$1" tmp.json && @1@ \'@2@\' tmp.json > patched.json && @0@ --json-input patched.json "$2"'.format(
                qpdf.full_path(),
                jq.full_path(),
                jq_filter,
            ),
            'sh',
            '@INPUT@',
            '@OUTPUT@',
        ],
        build_by_default: true,
    )
else
    # No embedding requested, build final PDF directly
    patch_target = custom_target(
        'typst_compile',
        input: main_typ,
        output: final_pdf,
        command: typst_args,
        depend_files: project_sources,
        build_by_default: true,
    )
endif

# Step 3: Compile to HTML (experimental)
html_args = [
    typst,
    'compile',
    '--features', 'html',
    embed_args,
    '@INPUT@',
    '@OUTPUT@',
].flatten()

html_target = custom_target(
    'resume_html',
    input: main_typ,
    output: 'resume.html',
    command: html_args,
    depend_files: project_sources,
    build_by_default: true,
)

# Step 4: Convert HTML to GitHub-Flavored Markdown (if pandoc is available)
if pandoc.found()
    custom_target(
        'resume_markdown',
        input: html_target,
        output: 'resume.md',
        command: [
            pandoc.full_path(),
            '-f',
            'html',
            '-t',
            'gfm-raw_html',
            '--wrap=none',
            '@INPUT@',
            '-o',
            '@OUTPUT@',
        ],
        build_by_default: true,
    )
endif
