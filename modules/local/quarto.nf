process QUARTO {
    tag 'quarto'
    label 'process_single'

    container 'rocker/verse:latest'
    containerOptions = '-u $(id -u):$(id -g) -e USERID=$UID -e XDG_CACHE_HOME=tmp/quarto_cache_home -e XDG_DATA_HOME=tmp/quarto_data_home -e QUARTO_PRINT_STACK=true'
    stageInMode = 'copy'
    afterScript = 'rm -rf tmp'

    input:
    path notebook
    path pfiles, stageAs: 'quarto/*'

    output:
    path "*_report.html", emit: report
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def qparams = pfiles ? : ''
    """
    quarto \\
        render \\
        $notebook \\
        $qparams

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$( quarto --version )
    END_VERSIONS
    """
}
