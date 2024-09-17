include { csvRecordToInputTuple } from './functions/utils'
include { QUALITY_CHECK         } from './subworkflows/local/quality_check/main.nf'
include { PROFILE_GENOME        } from './subworkflows/local/profile_genome/main.nf'

include { QUARTO_RENDER_PROJECT  } from "$projectDir/modules/local/quarto/render/main"
include { QUARTO_RENDER_NOTEBOOK } from "$projectDir/modules/local/quarto/render/main"

workflow {
    // Preparation
    ch_input = Channel.fromPath ( params.samplesheet, checkIfExists: true )
        .splitCsv ( header: [ 'id', 'read1', 'read2' ], skip: 1 )
        .map { entry -> csvRecordToInputTuple( entry ) }
    ch_quarto_metadata = Channel.fromPath( "$projectDir/assets/notebooks/_quarto.yml", checkIfExists: true )

    // Analysis
    if ( params.run_quality_check ) {
        QUALITY_CHECK (
            ch_input,
            ch_quarto_metadata
        )
    }
    if ( params.run_profile_genome ) {
        PROFILE_GENOME (
            ch_input,
            ch_quarto_metadata
        )
    }

    // // Final report
    QUARTO_RENDER_PROJECT(
        files( params.project_directory, type: 'file', checkIfExists: true ),
        QUALITY_CHECK.out.report_cache.mix(
            PROFILE_GENOME.out.report_cache
        ).toList(),
        QUALITY_CHECK.out.report.mix(
            PROFILE_GENOME.out.report
        ).toList()
    )
    QUARTO_RENDER_NOTEBOOK(
        file("$projectDir/assets/notebooks/index.qmd"),
        QUALITY_CHECK.out.log_files.mix(
            PROFILE_GENOME.out.log_files
        ).collect{ meta, file -> file },
        Channel.fromPath( params.project_directory, type: 'file', checkIfExists: true ).toList().map { list -> list.findAll { !it.name.endsWith('index.qmd') } }
    )
}
