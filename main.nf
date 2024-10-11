include { FASTQC          } from './modules/nf-core/fastqc/main'
include { MERYL_COUNT     } from './modules/nf-core/meryl/count/main'
include { MERYL_UNIONSUM  } from './modules/nf-core/meryl/unionsum/main'
include { MERYL_HISTOGRAM } from './modules/nf-core/meryl/histogram/main'
include { GENOMESCOPE2    } from './modules/nf-core/genomescope2/main'
include { QUARTO_MULTIQC  } from './modules/local/quarto/multiqc/main'
include { BUSCO_BUSCO     } from './modules/nf-core/busco/busco/main'

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
    log_files = Channel.empty()
    log_files = log_files.mix(
        Channel.fromPath( "$projectDir/assets/samplesheet.csv", checkIfExists: true )
            .map { fn -> [[ id: fn.baseName ], fn ] }
    )

    // Analysis
    if ( params.run_fastqc ) {
        FASTQC ( ch_input )
        log_files = log_files.mix( FASTQC.out.zip )
    }
    if ( params.run_genomescope ){
        MERYL_COUNT ( ch_input, params.kmer_size )
        MERYL_UNIONSUM ( MERYL_COUNT.out.meryl_db, params.kmer_size )
        MERYL_HISTOGRAM ( MERYL_UNIONSUM.out.meryl_db, params.kmer_size )
        GENOMESCOPE2 ( MERYL_HISTOGRAM.out.hist )
        log_files = log_files.mix( *GENOMESCOPE2.out[0..3] )
    }

    if( params.run_busco ) {
        ch_in_busco = Channel.fromPath(params.genome, checkIfExists: true)
            .map { genome -> tuple( [id: genome.baseName], genome ) }
            .combine( Channel.of('bacteria_odb10', 'archaea_odb10') )
            .multiMap { meta, genome, lineage ->
                genome: tuple(meta, genome)
                mode: 'genome'
                lineage: lineage
            }
        BUSCO_BUSCO( ch_in_busco, [], [] )
        log_files = log_files.mix( BUSCO_BUSCO.out.short_summaries_txt )
    }

    def run_modules = params.keySet().findAll{ it.startsWith('run_') }
    // Report
    QUARTO_MULTIQC(
        file( params.quarto_mqc_report, checkIfExists: true ),
        log_files.collect{ it[1] },
        Channel.value(params.subMap(run_modules).collect{ k, v -> "$k: ${v}" }.join('\n')).collectFile(),
        file( params.multiqc_config, checkIfExists: true ),
    )
}
