include { FASTQC          } from './modules/nf-core/fastqc/main'
include { MERYL_COUNT     } from './modules/nf-core/meryl/count/main'
include { MERYL_UNIONSUM  } from './modules/nf-core/meryl/unionsum/main'
include { MERYL_HISTOGRAM } from './modules/nf-core/meryl/histogram/main'
include { GENOMESCOPE2    } from './modules/nf-core/genomescope2/main'

workflow {
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

    FASTQC ( ch_input )
    MERYL_COUNT ( ch_input, params.kmer_size )
    MERYL_UNIONSUM ( MERYL_COUNT.out.meryl_db, params.kmer_size )
    MERYL_HISTOGRAM ( MERYL_UNIONSUM.out.meryl_db, params.kmer_size )
    GENOMESCOPE2 ( MERYL_HISTOGRAM.out.hist )

//     ch_quarto_files = Channel.empty().mix(*GENOMESCOPE2.out[0..3]).map { it[1] }
//     QUARTO ( 
//         file( params.gs2_panel_qmd, checkIfExists: true ),
//         ch_quarto_files.collect()
//     )
//     mqc_files = FASTQC.out.zip.map{ it[1] }
//         .mix( QUARTO.out.html )
//     MULTIQC( mqc_files.collect(), [], [], [] )

}
