process UPLOAD_TO_LIMELIGHT {
    label 'process_low'
    debug true

    input:
        path limelight_xml
        path mzml_files
        val webapp_url
        val project_id
        val search_long_name
        val search_short_name
        val limelight_upload_key
        val tags
        env LIMELIGHT_SUBMIT_JAVA_PARAMS

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
        --user-submit-import-key=${limelight_upload_key} \
        --project-id=${project_id} \
        --limelight-xml-file=${limelight_xml} \
        --search-description="${search_long_name}" \
        --search-short-label="${search_short_name}" \
        --send-search-path \
        ${scans_param} \
        ${tags_param}
    echo "Done!" # Needed for proper exit
    """

    //--scan-file=${mzml} \
}
