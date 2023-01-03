process CONVERT_TO_LIMELIGHT_XML {
    publishDir "${params.result_dir}/limelight", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true

    input:
        path pepxml
        path pout
        path fasta
        path comet_params
        env CONVERTER_JAVA_PARAMS

    output:
        path("${pepxml.baseName}.limelight.xml"), emit: limelight_xml

    script:
    """
    echo "Running Limelight XML conversion..."
        cometPercolator2LimelightXML \
        -c ${comet_params} \
        -f ${fasta} \
        -p ${pout} \
        -d . \
        -o ${pepxml.baseName}.limelight.xml \
        -v

    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "${pepxml.baseName}.limelight.xml"
    """
}
