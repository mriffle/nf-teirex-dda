// Modules
include { MSCONVERT } from "../modules/msconvert"
include { COMET } from "../modules/comet"
include { PERCOLATOR } from "../modules/percolator"
include { FILTER_PIN } from "../modules/filter_pin"
include { COMBINE_PIN_FILES } from "../modules/combine_pin_files"
include { ADD_FASTA_TO_COMET_PARAMS } from "../modules/add_fasta_to_comet_params"
include { CONVERT_TO_LIMELIGHT_XML } from "../modules/limelight_xml_convert"
include { UPLOAD_TO_LIMELIGHT } from "../modules/limelight_upload"

workflow wf_comet_percolator {

    take:
        spectra_file_ch
        comet_params
        fasta
        from_raw_files
    
    main:

        // modify comet.params to specify search database
        ADD_FASTA_TO_COMET_PARAMS(comet_params, fasta)
        new_comet_params = ADD_FASTA_TO_COMET_PARAMS.out.comet_fasta_params

        // convert raw files to mzML files if necessary
        if(from_raw_files) {
            mzml_file_ch = MSCONVERT(spectra_file_ch)
        } else {
            mzml_file_ch = spectra_file_ch
        }

        COMET(mzml_file_ch, new_comet_params, fasta)
        FILTER_PIN(COMET.out.pin)
        filtered_pin_files = FILTER_PIN.out.filtered_pin.collect()

        COMBINE_PIN_FILES(filtered_pin_files)

        PERCOLATOR(COMBINE_PIN_FILES.out.combined_pin)

        if (params.limelight_upload) {

            CONVERT_TO_LIMELIGHT_XML(
                COMET.out.pepxml.collect(), 
                PERCOLATOR.out.pout, 
                fasta, 
                new_comet_params
            )

            UPLOAD_TO_LIMELIGHT(
                CONVERT_TO_LIMELIGHT_XML.out.limelight_xml,
                mzml_file_ch.collect(),
                params.limelight_webapp_url,
                params.limelight_project_id,
                params.limelight_search_description,
                params.limelight_search_short_name,
                params.limelight_tags,
            )
        }

}
