include { FASTQC          } from "$projectDir/modules/nf-core/fastqc/main"
include { MERYL_COUNT     } from "$projectDir/modules/nf-core/meryl/count/main"
include { MERYL_UNIONSUM  } from "$projectDir/modules/nf-core/meryl/unionsum/main"
include { MERYL_HISTOGRAM } from "$projectDir/modules/nf-core/meryl/histogram/main"
include { GENOMESCOPE2    } from "$projectDir/modules/nf-core/genomescope2/main"
include { QUARTO          } from "$projectDir/modules/local/quarto"
include { MULTIQC         } from "$projectDir/modules/nf-core/multiqc/main"

workflow {
    ch_input = Channel.fromPath ( params.samplesheet, checkIfExists: true )
        .splitCsv ( header: [ 'id', 'read1', 'read2' ], skip: 1 )
        .map { entry -> [ [id: entry.id ], [ file( entry.read1, checkIfExists: true ), file( entry.read2, checkIfExists: true ) ] ] }

    FASTQC ( ch_input )
    MERYL_COUNT ( ch_input )
    MERYL_UNIONSUM ( MERYL_COUNT.out.meryl_db )
    MERYL_HISTOGRAM ( MERYL_UNIONSUM.out.meryl_db )
    GENOMESCOPE2 ( MERYL_HISTOGRAM.out.hist )

    ch_quarto_files = FASTQC.out.html.map { it[1] }
    QUARTO ( 
        file( params.report_template, checkIfExists: true ),
        ch_quarto_files.collect()
    )
    mqc_files = FASTQC.out.zip.map{ it[1] }
    MULTIQC( mqc_files.collect(), [], [], [] )

}