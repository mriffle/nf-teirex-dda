process UPLOAD_TO_LIMELIGHT {
    publishDir "${params.result_dir}/limelight", failOnError: true, mode: 'copy'
    label 'process_low'
    debug true
    container 'mriffle/limelight-submit-import:4'
    secret 'LIMELIGHT_SUBMIT_UPLOAD_KEY'

    input:
        path limelight_xml
        path mzml_files
        val webapp_url
        val project_id
        val search_long_name
        val search_short_name
        val tags
        env LIMELIGHT_SUBMIT_JAVA_PARAMS

    output:
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:

    tags_param = ''
    if(tags) {
        tags_param = "--search-tag=\"${tags.split(',').join('\" --search-tag=\"')}\""
    }

    scans_param = "--scan-file=${(mzml_files as List).join(' --scan-file=')}"

    """
    echo "Submitting search results for Limelight import..."
        limelightSubmitImport \
        --retry-count-limit=5 \
        --limelight-web-app-url=${webapp_url} \
        --user-submit-import-key=\$LIMELIGHT_SUBMIT_UPLOAD_KEY \
        --project-id=${project_id} \
        --limelight-xml-file=${limelight_xml} \
        --search-description="${search_long_name}" \
        --search-short-label="${search_short_name}" \
        --send-search-path \
        ${scans_param} \
        ${tags_param} \
        1>limelight-submit-upload.stdout 2>limelight-submit-upload.stderr
    echo "Done!" # Needed for proper exit
    """
}
