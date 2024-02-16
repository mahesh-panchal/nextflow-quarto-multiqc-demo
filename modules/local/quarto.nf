process QUARTO {
    input:
    path notebook
    path pfiles, stageAs: 'quarto/*', arity: '1..*'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def qparams = pfiles ? "-P fastqc:quarto" : ''
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

    output:
    path "*.html"       , emit: report
    path "versions.yml" , emit: versions
}
