include { FASTQC } from "$projectDir/modules/nf-core/fastqc/main"
include { QUARTO } from "$projectDir/modules/local/quarto"

workflow {
    ch_input = Channel.fromPath ( params.samplesheet, checkIfExists: true )
        .splitCsv ( header: [ 'id', 'read1', 'read2' ], skip: 1 )
        .map { entry -> [ [id: entry.id ], [ file( entry.read1, checkIfExists: true ), file( entry.read2, checkIfExists: true ) ] ] }

    FASTQC ( ch_input ) 

    ch_quarto_files = FASTQC.out.html.map { it[1] }
    QUARTO ( 
        file( params.report_template, checkIfExists: true ),
        ch_quarto_files.collect()
    )
}