include { FASTQC } from "$projectDir/modules/nf-core/fastqc/main"

include { QUARTO_RENDER_NOTEBOOK } from "$projectDir/modules/local/quarto/render/main"
include { mapToYamlFile          } from "$projectDir/functions/utils"

workflow QUALITY_CHECK {
    take:
    ch_input
    ch_quarto_configs

    main:
    FASTQC ( ch_input )

    def quarto_metadata = [ 
        run_fastqc: true,
        debug: 'debug' in workflow.profile.tokenize(',')
    ] 
    QUARTO_RENDER_NOTEBOOK (
        file( params.quality_check_notebook, checkIfExists: true ),
        FASTQC.out.zip.collect{ it[1] },
        ch_quarto_configs.mix(mapToYamlFile(quarto_metadata,'_metadata.yml')).toList()
    )

    emit:
    report       = QUARTO_RENDER_NOTEBOOK.out.report
    report_cache = QUARTO_RENDER_NOTEBOOK.out.cache
    log_files    = FASTQC.out.zip
}