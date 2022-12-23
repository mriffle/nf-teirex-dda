process COMET_ONCE {
    publishDir "${params.result_dir}/${params.run_name}_comet", failOnError: true
    label 'process_high'
    debug true

    input:
        path mzml_file
        path comet_params_file
	path mzml_file

    output:
        path path("${mzml_file.baseName}.pep.xml")
        path path("${mzml_file.baseName}.pin")

    script:
    """
    comet.linux.exe \
        -P${comet_params_file} \
        ${mzml_file}
    echo "DONE!" # Needed for proper exit
    """

    stub:
    """
    touch "${mzml_file.baseName}.pep.xml"
    touch "${mzml_file.baseName}.pin"
    """
}
