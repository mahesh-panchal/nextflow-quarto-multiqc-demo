include { MERYL_COUNT            } from "$projectDir/modules/nf-core/meryl/count/main"
include { MERYL_UNIONSUM         } from "$projectDir/modules/nf-core/meryl/unionsum/main"
include { MERYL_HISTOGRAM        } from "$projectDir/modules/nf-core/meryl/histogram/main"
include { GENOMESCOPE2           } from "$projectDir/modules/nf-core/genomescope2/main"

include { QUARTO_RENDER_NOTEBOOK } from "$projectDir/modules/local/quarto/render/main"
include { mapToYamlFile          } from "$projectDir/functions/utils"

workflow PROFILE_GENOME {
    take:
    ch_input
    ch_quarto_configs

    main:
    MERYL_COUNT ( ch_input, params.kmer_size )
    MERYL_UNIONSUM ( MERYL_COUNT.out.meryl_db, params.kmer_size )
    MERYL_HISTOGRAM ( MERYL_UNIONSUM.out.meryl_db, params.kmer_size )
    GENOMESCOPE2 ( MERYL_HISTOGRAM.out.hist )

    def quarto_metadata = [ 
        run_genomescope2: true,
        debug: 'debug' in workflow.profile.tokenize(',')
    ] 
    QUARTO_RENDER_NOTEBOOK (
        file( params.profile_genome_notebook, checkIfExists: true ),
        Channel.empty().mix( *GENOMESCOPE2.out[0..3] ).collect{ it[1] },
        ch_quarto_configs.mix(mapToYamlFile(quarto_metadata,'_metadata.yml')).toList()
    )

    emit:
    report       = QUARTO_RENDER_NOTEBOOK.out.report
    report_cache = QUARTO_RENDER_NOTEBOOK.out.cache
    log_files    = Channel.empty().mix( *GENOMESCOPE2.out[0..3] )
}