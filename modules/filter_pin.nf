process FILTER_PIN {
    publishDir "${params.result_dir}/percolator", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true
    container 'mriffle/filter-pin:1.0.0'

    input:
        each path(pin)

    output:
        path("${pin.baseName}.filtered.pin"), emit: filtered_pin
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Removing all non rank one hits from Percolator input file..."
        filterPIN ${pin} >${pin.baseName}.filtered.pin 2>${pin.baseName}.filtered.pin.stderr

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${pin.baseName}.filtered.pin"
    """
}
