process CONVERT_TO_LIMELIGHT_XML {
    publishDir "${params.result_dir}/limelight", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true
    container 'mriffle/comet-percolator-to-limelight:2.6.4'

    input:
        path pepxml
        path pout
        path fasta
        path comet_params
        env CONVERTER_JAVA_PARAMS

    output:
        path("results.limelight.xml"), emit: limelight_xml
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Running Limelight XML conversion..."
        cometPercolator2LimelightXML \
        -c ${comet_params} \
        -f ${fasta} \
        -p ${pout} \
        -d . \
        -o results.limelight.xml \
        -v \
        1>limelight-xml-convert.stdout 2>limelight-xml-convert.stderr

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "results.limelight.xml"
    """
}
