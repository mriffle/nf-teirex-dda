process FILTER_PIN {
    publishDir "${params.result_dir}/percolator", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true

    input:
        path pin

    output:
        path("${pin.baseName}.filtered.pin"), emit: filtered_pin

    script:
    """
    echo "Removing all non rank one hits from Percolator input file..."
        filterPIN ${pin} >${pin.baseName}.filtered.pin

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${pepxml.baseName}.limelight.xml"
    """
}
