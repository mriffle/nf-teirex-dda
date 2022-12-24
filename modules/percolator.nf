process PERCOLATOR {
    publishDir "${params.result_dir}/percolator", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true

    input:
        path pin_file

    output:
        path("${pin_file.baseName}.pout.xml")

    script:
    """
    percolator \
        -X "${pin_file.baseName}.pout.xml" \
        ${pin_file}
    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${pin_file.baseName}.pout.xml"
    """
}
