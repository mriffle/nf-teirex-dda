process COMET_ONCE {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high'
    debug true

    input:
        path mzml_file
        path comet_params_file
        path fasta_file

    output:
        path("${mzml_file.baseName}.pep.xml"), emit: pepxml
        path("${mzml_file.baseName}.pin"), emit: pin

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
