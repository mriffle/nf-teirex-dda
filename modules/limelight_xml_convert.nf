process CONVERT_TO_LIMELIGHT_XML {
    publishDir "${params.result_dir}/limelight", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true

    input:
        path pepxml
        path pout
        path fasta
        path comet_params

    output:
        path("${pepxml.baseName}.limelight.xml")

    script:
    """
    echo "Running Limelight XML conversion..."
        -c ${comet_params} \
        -f ${fasta} \
        -p ${pout} \
        -d . \
        -o "${pepxml.baseName}.limelight.xml" \
        -v

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${pepxml.baseName}.limelight.xml"
    """
}
