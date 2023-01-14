// Modules
include { COMET_MULTI_FILE } from "../modules/comet"
include { COMET_SINGLE_FILE } from "../modules/comet"
include { PERCOLATOR } from "../modules/percolator"
include { FILTER_PIN } from "../modules/filter_pin"
include { COMBINE_PIN_FILES } from "../modules/combine_pin_files"
include { ADD_FASTA_TO_COMET_PARAMS } from "../modules/add_fasta_to_comet_params"
include { CONVERT_TO_LIMELIGHT_XML } from "../modules/limelight_xml_convert"

workflow wf_comet_percolator_local {

    take:
        mzml_files
        comet_params
        fasta
    
    main:

        // modify comet.params to specify search database
        new_comet_params = ADD_FASTA_TO_COMET_PARAMS(comet_params, fasta)

        COMET_MULTI_FILE(mzml_files, new_comet_params, fasta)

        FILTER_PIN(COMET_MULTI_FILE.out.pin)
        filtered_pin_files = FILTER_PIN.out.collect()

        COMBINE_PIN_FILES(filtered_pin_files)

        PERCOLATOR(COMBINE_PIN_FILES.out.combined_pin)

        CONVERT_TO_LIMELIGHT_XML(COMET_MULTI_FILE.out.pepxml, PERCOLATOR.out.pout, fasta, new_comet_params, params.limelight_xml_conversion_java_params)
    
    emit:
        CONVERT_TO_LIMELIGHT_XML.out.limelight_xml


}
