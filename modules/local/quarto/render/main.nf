process QUARTO_RENDER_NOTEBOOK {
    tag "$notebook.baseName"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    input:
    path notebook
    path log_files, stageAs: 'log_files/*'
    path config_files // params.yml, and other environment files supplied here.

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: notebook.baseName
    def notebook_params = config_files.find{ file -> file.baseName == 'params.yml' } ? '--execute-params params.yml' : ''
    """    
    quarto \\
        render \\
        $notebook \\
        $notebook_params \\
        $args \\
        --output ${prefix}.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch ${prefix}.html
    mkdir -p _freeze/${notebook.baseName}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
    END_VERSIONS
    """

    output:
    path "*.html"                                   , emit: report
    path "_freeze/${notebook.baseName}", type: 'dir', emit: cache   , optional: true
    path "versions.yml"                             , emit: versions
}

process QUARTO_RENDER_PROJECT {
    tag "Project Report"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    input:
    path project
    path freeze_cache, stageAs: '_freeze/*'
    path config_files // params.yml, and other environment files supplied here.

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: 'report'
    def project_params = config_files.find{ file -> file.baseName == 'params.yml' } ? '--execute-params params.yml' : ''
    """
    quarto \\
        render \\
        . \\
        $project_params \\
        $args \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch ${prefix}.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
    END_VERSIONS
    """

    output:
    path "_book/index.html", emit: report
    path "versions.yml"    , emit: versions
}
