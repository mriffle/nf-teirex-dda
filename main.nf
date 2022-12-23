#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Modules
include { COMET_ONCE } from "./modules/comet"


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
    tags = tuple

    COMET_ONCE(mzml, comet_params, fasta)
    | set { quant_results }
}


//
// This is a dummy workflow for testing
//
workflow dummy {
    println "This is a workflow that doesn't do anything."
}

// Email notifications:
//workflow.onComplete { email() }
