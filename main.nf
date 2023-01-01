#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Modules
include { COMET_ONCE } from "./modules/comet"
include { PERCOLATOR } from "./modules/percolator"
include { CONVERT_TO_LIMELIGHT_XML } from "./modules/limelight_xml_convert"

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
// The main workflow
//
workflow {
    fasta = file(params.fasta, checkIfExists: true)
    mzml = file(params.mzml, checkIfExists: true)
    comet_params = file(params.comet_params, checkIfExists: true)

    COMET_ONCE(mzml, comet_params, fasta)
    PERCOLATOR(COMET_ONCE.out.pin)
    CONVERT_TO_LIMELIGHT_XML(COMET_ONCE.out.pepxml, PERCOLATOR.out.pout, fasta, comet_params, params.limelight_xml_conversion_params)

}


//
// This is a dummy workflow for testing
//
workflow dummy {
    println "This is a workflow that doesn't do anything."
}

// Email notifications:
//workflow.onComplete { email() }
