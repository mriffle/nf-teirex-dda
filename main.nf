#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Modules
include { COMET_MULTIPLE_FILES_SEQUENTIALLY } from "./modules/comet"
include { PERCOLATOR } from "./modules/percolator"
include { FILTER_PIN } from "./modules/filter_pin"
include { COMBINE_PIN_FILES } from "./modules/combine_pin_files"
include { CONVERT_TO_LIMELIGHT_XML } from "./modules/limelight_xml_convert"
include { UPLOAD_TO_LIMELIGHT } from "./modules/limelight_upload"

//
// The main workflow
//
workflow {
    fasta = file(params.fasta, checkIfExists: true)
    comet_params = file(params.comet_params, checkIfExists: true)
    mzml_dir = file(params.mzml_dir, checkIfExists: true)

    // get our mzML files, die if none are found
    mzml_files = file("$mzml_dir/*.mzML")
    if(mzml_files.size() < 1) {
        error "No mzML files in $mzml_dir"
    }
    

    COMET_MULTIPLE_FILES_SEQUENTIALLY(mzml_files, comet_params, fasta)

    FILTER_PIN(COMET_MULTIPLE_FILES_SEQUENTIALLY.out.pin)
    filtered_pin_files = FILTER_PIN.out.collect()

    COMBINE_PIN_FILES(filtered_pin_files)

    PERCOLATOR(COMBINE_PIN_FILES.out.combined_pin)

    CONVERT_TO_LIMELIGHT_XML(COMET_MULTIPLE_FILES_SEQUENTIALLY.out.pepxml, PERCOLATOR.out.pout, fasta, comet_params, params.limelight_xml_conversion_java_params)

    if (params.limelight_upload) {
        UPLOAD_TO_LIMELIGHT(
            CONVERT_TO_LIMELIGHT_XML.out.limelight_xml,
            mzml,
            params.limelight_webapp_url,
            params.limelight_project_id,
            params.limelight_search_description,
            params.limelight_search_short_name,
            params.limelight_upload_key,
            params.limelight_submit_import_java_params
        )
    }
}

//
// Used for email notifications
//
def email() {
    // Create the email text:
    def (subject, msg) = EmailTemplate.email(workflow, params)
    // Send the email:
    if (params.email) {
        sendMail(
            to: "$params.email",
            subject: subject,
            body: msg
        )
    }
}

//
// This is a dummy workflow for testing
//
workflow dummy {
    println "This is a workflow that doesn't do anything."
}

// Email notifications:
//workflow.onComplete { email() }
