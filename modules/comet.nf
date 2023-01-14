process COMET_MULTI_FILE {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high'
    debug true
    container 'mriffle/comet:2022012'

    input:
        path mzml_files
        path comet_params_file
        path fasta_file

    output:
        path("*.pep.xml"), emit: pepxml
        path("*.pin"), emit: pin

    script:
    """
    echo "Running comet..."
    comet \
        -P${comet_params_file} \
        ${(mzml_files as List).join(' ')}
    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${mzml_file.baseName}.pep.xml"
    touch "${mzml_file.baseName}.pin"
    """
}

process COMET_SINGLE_FILE {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high'
    debug true
    container 'mriffle/comet:2022012'

    input:
        path mzml_file
        path comet_params_file
        path fasta_file

    output:
        path("*.pep.xml"), emit: pepxml
        path("*.pin"), emit: pin

    script:
    """
    echo "Running comet..."
    comet \
        -P${comet_params_file} \
        ${mzml_file}
    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${mzml_file.baseName}.pep.xml"
    touch "${mzml_file.baseName}.pin"
    """
}
