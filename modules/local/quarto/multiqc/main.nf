process QUARTO_MULTIQC {
    tag 'report'
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    input:
    path notebook
    path log_files, stageAs: 'log_files/*'
    path 'params.yml'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = notebook.baseName
    """
    # Link params to meta data
    ln -s params.yml _quarto.yml
    
    quarto \\
        render \\
        $notebook \\
        --execute-params params.yml \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
        multiqc: \$(multiqc --version | sed '1!d; s/.*version //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = notebook.baseName
    """
    touch ${prefix}.html
    mkdir multiqc
    touch multiqc/quarto-multiqc-report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$(quarto --version)
        multiqc: \$(multiqc --version | sed '1!d; s/.*version //')
    END_VERSIONS
    """

    output:
    path "${prefix}.html", emit: quarto_report
    path "*/*report.html", emit: multiqc_report
    path "versions.yml", emit: versions
}
