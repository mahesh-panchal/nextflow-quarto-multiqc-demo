include { FASTQC          } from './modules/nf-core/fastqc/main'
include { MERYL_COUNT     } from './modules/nf-core/meryl/count/main'
include { MERYL_UNIONSUM  } from './modules/nf-core/meryl/unionsum/main'
include { MERYL_HISTOGRAM } from './modules/nf-core/meryl/histogram/main'
include { GENOMESCOPE2    } from './modules/nf-core/genomescope2/main'
include { QUARTO_MULTIQC  } from './modules/local/quarto/multiqc/main'

workflow {
    // Preparation
    ch_input = Channel.fromPath ( params.samplesheet, checkIfExists: true )
        .splitCsv ( header: [ 'id', 'read1', 'read2' ], skip: 1 )
        .map { entry -> 
            [ 
                [ id: entry.id ], 
                [ 
                    file( entry.read1, checkIfExists: true ), 
                    file( entry.read2, checkIfExists: true ) 
                ] 
            ] 
        }

    // Analysis
    FASTQC ( ch_input )
    MERYL_COUNT ( ch_input, params.kmer_size )
    MERYL_UNIONSUM ( MERYL_COUNT.out.meryl_db, params.kmer_size )
    MERYL_HISTOGRAM ( MERYL_UNIONSUM.out.meryl_db, params.kmer_size )
    GENOMESCOPE2 ( MERYL_HISTOGRAM.out.hist )

    // Report
    log_files = FASTQC.out.zip
        .mix( *GENOMESCOPE2.out[0..3] )
        .map { it[1] } // take files only
    QUARTO_MULTIQC(
        file( params.quarto_mqc_report, checkIfExists: true ),
        log_files.collect()
    )
}
