// Modules
include { MSCONVERT } from "../modules/msconvert"
include { COMET_SEARCH } from "../modules/comet"
include { COMET_BUILD_INDEX } from "../modules/comet"
include { PERCOLATOR } from "../modules/percolator"
include { FILTER_PIN } from "../modules/filter_pin"
include { COMBINE_PIN_FILES } from "../modules/combine_pin_files"
include { CONVERT_TO_LIMELIGHT_XML } from "../modules/limelight_xml_convert"
include { UPLOAD_TO_LIMELIGHT } from "../modules/limelight_upload"

workflow wf_comet_percolator {

    take:
        spectra_file_ch
        comet_params
        fasta
        from_raw_files
        do_use_fasta_index
    
    main:

        // convert raw files to mzML files if necessary
        if(from_raw_files) {
            mzml_file_ch = MSCONVERT(spectra_file_ch)
        } else {
            mzml_file_ch = spectra_file_ch
        }

        if(do_use_fasta_index) {
            // build index w/ comet first
            COMET_BUILD_INDEX(comet_params, fasta)
            fasta_index = COMET_BUILD_INDEX.out.fasta_index
            fasta_to_use = fasta_index
        } else {
            fasta_to_use = fasta
        }

        // do comet search
        COMET_SEARCH(mzml_file_ch, comet_params, fasta_to_use)

        // do post processing with percolator
        FILTER_PIN(COMET_SEARCH.out.pin)
        filtered_pin_files = FILTER_PIN.out.filtered_pin.collect()
        COMBINE_PIN_FILES(filtered_pin_files)
        PERCOLATOR(COMBINE_PIN_FILES.out.combined_pin)

        if (params.limelight_upload) {

            CONVERT_TO_LIMELIGHT_XML(
                COMET_SEARCH.out.pepxml.collect(), 
                PERCOLATOR.out.pout, 
                fasta, 
                comet_params
            )

            UPLOAD_TO_LIMELIGHT(
                CONVERT_TO_LIMELIGHT_XML.out.limelight_xml,
                mzml_file_ch.collect(),
                fasta,
                params.limelight_webapp_url,
                params.limelight_project_id,
                params.limelight_search_description,
                params.limelight_search_short_name,
                params.limelight_tags,
            )
        }

}
