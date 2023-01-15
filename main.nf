#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// modules
include { UPLOAD_TO_LIMELIGHT } from "./modules/limelight_upload"

// Sub workflows
include { wf_comet_percolator } from "./workflows/comet_percolator"
include { wf_comet_percolator_local } from "./workflows/comet_percolator_local"

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

    /**
     * The 'standard' workflow runs locally, and as such, we don't want comet to
     * run in parallel on all input mzml files--we want to pass all mzML files to
     * a single invocation of comet, where it will run them all serially.
     */
    if(workflow.profile == 'standard') {
        limelight_xml = wf_comet_percolator_local(mzml_files, comet_params, fasta)
    } else {
        mzml_files_ch = Channel.fromList(mzml_files)
        limelight_xml = wf_comet_percolator(mzml_files_ch, comet_params, fasta)
    }

    if (params.limelight_upload) {
        UPLOAD_TO_LIMELIGHT(
            limelight_xml,
            mzml_files,
            params.limelight_webapp_url,
            params.limelight_project_id,
            params.limelight_search_description,
            params.limelight_search_short_name,
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
