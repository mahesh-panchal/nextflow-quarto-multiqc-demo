process QUARTO {
    input:
    path notebook
    path pfiles, stageAs: 'images/*', arity: '1..*'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    quarto \\
        render \\
        $notebook \\
        -P image_path:images

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quarto: \$( quarto --version )
    END_VERSIONS
    """

    output:
    path "*.html"       , emit: html
    path "versions.yml" , emit: versions
}
