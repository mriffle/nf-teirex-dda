process COMET {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'quay.io/protio/comet:2023020-prerelease'

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
        > >(tee "${mzml_file.baseName}.comet.stdout") 2> >(tee "${mzml_file.baseName}.comet.stderr" >&2)

    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${mzml_file.baseName}.pep.xml"
    touch "${mzml_file.baseName}.pin"
    """
}
