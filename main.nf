#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// modules
include { CONVERT_TO_LIMELIGHT_XML } from "./modules/limelight_xml_convert"

// Sub workflows
include { wf_comet_percolator } from "./workflows/comet_percolator"

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

    limelight_xml = wf_comet_percolator(mzml_files, comet_params, fasta)

    if (params.limelight_upload) {
        UPLOAD_TO_LIMELIGHT(
            limelight_xml,
            mzml_files,
            params.limelight_webapp_url,
            params.limelight_project_id,
            params.limelight_search_description,
            params.limelight_search_short_name,
            params.limelight_upload_key,
            params.limelight_tags,
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
