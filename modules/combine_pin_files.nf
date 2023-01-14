process COMBINE_PIN_FILES {
    publishDir "${params.result_dir}/percolator", failOnError: true, mode: 'copy'
    label 'process_high'
    debug true
    container 'ubuntu:22.04'

    input:
        path pin_files

    output:
        path("combined.filtered.pin"), emit: combined_pin

    script:
    command = ''

    // sort the files so subsequent runs of pipeline process files in same order
    pin_files.sort().indexed().collect { index, item ->
        if(index == 0) {
            command = command + "cat $item >combined.filtered.pin\n"
        } else {
            command = command + "sed 1d $item >>combined.filtered.pin\n"
        }
    }


    """
    echo "Combining pin files..."
    $command
    echo "DONE!" # Needed for proper exit
    """


}