process COMET_SEARCH {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'quay.io/protio/comet:2023020-exp'

    input:
        path mzml_file
        path comet_params_file
        path fasta_index
        path fasta_file

    output:
        path("*.pep.xml"), emit: pepxml
        path("*.pin"), emit: pin
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """

    echo "Adding FASTA index to comet.params..."
    sed -e 's/database_name = \\S\\+/database_name = ${fasta_file}/g' ${comet_params_file} >comet.fasta.params 2> >(tee add-fasta-index-to-params.stderr >&2)

    echo "Running comet (search)..."
    comet \
        -Pcomet.fasta.params \
        ${mzml_file} \
        > >(tee "${mzml_file.baseName}.comet.stdout") 2> >(tee "${mzml_file.baseName}.comet.stderr" >&2)

    echo "DONE!" # Needed for proper exit
    """
}

process COMET_BUILD_INDEX {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_high_constant'
    container 'quay.io/protio/comet:2023020-exp'

    input:
        path comet_params_file
        path fasta_file

    output:
        path("${fasta_file}.idx"), emit: fasta_index
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Adding FASTA to comet.params..."
    sed -e 's/database_name = \\S\\+/database_name = ${fasta_file}/g' ${comet_params_file} >comet.fasta.params 2> >(tee add-fasta-to-params.stderr >&2)


    echo "Running comet (build index)..."
    comet \
        -Pcomet.fasta.params \
        -i \
        > >(tee "comet-build-index.stdout") 2> >(tee "comet-build-index.stderr" >&2)

    echo "DONE!" # Needed for proper exit
    """
}