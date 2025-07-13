process PERCOLATOR {
    publishDir "${params.result_dir}/percolator", failOnError: true, mode: 'copy'
    label 'process_medium'
    label 'process_high_memory'
    label 'process_long'
    container params.images.percolator

    input:
        path pin_file
        val import_decoys

    output:
        path("${pin_file.baseName}.pout.xml"), emit: pout
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:

    decoy_import_flag = import_decoys ? '-Z' : ''

    """
    echo "Running percolator..."
    percolator \
        ${decoy_import_flag} -X "${pin_file.baseName}.pout.xml" \
        ${pin_file} \
        > >(tee "percolator.stdout") 2> >(tee "percolator.stderr" >&2)
    echo "Done!" # Needed for proper exit
    """
}
