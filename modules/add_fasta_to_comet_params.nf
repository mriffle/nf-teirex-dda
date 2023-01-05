process ADD_FASTA_TO_COMET_PARAMS {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_low_constant'
    debug true

    input:
        path comet_params
        path fasta

    output:
        path("comet.fasta.params"), emit: comet_fasta_params

    script:

    """
    echo "Adding FASTA to comet.params..."

    sed -e 's/database_name = \\S\\+/database_name = $fasta/g' $comet_params >comet.fasta.params

    echo "DONE!" # Needed for proper exit
    """
}