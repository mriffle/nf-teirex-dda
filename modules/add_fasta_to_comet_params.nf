process ADD_FASTA_TO_COMET_PARAMS {
    publishDir "${params.result_dir}/comet", failOnError: true, mode: 'copy'
    label 'process_low_constant'
    container "${workflow.profile == 'aws' ? 'public.ecr.aws/docker/library/ubuntu:22.04' : 'ubuntu:22.04'}"

    input:
        path comet_params
        path fasta

    output:
        path("comet.fasta.params"), emit: comet_fasta_params
        path("*.stderr"), emit: stderr

    script:

    """
    echo "Adding FASTA to comet.params..."

    sed -e 's/database_name = \\S\\+/database_name = $fasta/g' $comet_params >comet.fasta.params 2> >(tee add-fasta-to-params.stderr >&2)

    echo "DONE!" # Needed for proper exit
    """
}