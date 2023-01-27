process COMET_MULTI_FILE {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'mriffle/comet:2022012'

    input:
        path mzml_files
        path comet_params_file
        path fasta_file

    output:
        path("*.pep.xml"), emit: pepxml
        path("*.pin"), emit: pin
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Running comet..."
    comet \
        -P${comet_params_file} \
        ${(mzml_files as List).join(' ')} \
        1>comet.stdout 2>comet.stderr

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
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Running comet..."
    comet \
        -P${comet_params_file} \
        ${mzml_file} \
        1>${mzml_file.baseName}.comet.stdout 2>${mzml_file.baseName}.comet.stderr

    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${mzml_file.baseName}.pep.xml"
    touch "${mzml_file.baseName}.pin"
    """
}
