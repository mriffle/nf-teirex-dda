// Modules/process for interacting with PanoramaWeb

def exec_java_command(mem) {
    def xmx = "-Xmx${mem.toGiga()-1}G"
    return "java -Djava.aws.headless=true ${xmx} -jar /usr/local/bin/PanoramaClient.jar"
}

process PANORAMA_GET_RAW_FILE_LIST {
    label 'process_low_constant'
    container 'mriffle/panorama-client:1.0.0'
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy'

    input:
        val web_dav_url

    output:
        path("panorama_files.txt"), emit: panorama_file_list
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Running file list from Panorama..."
        ${exec_java_command(task.memory)} \
        -l \
        -e raw \
        -w "${web_dav_url}"" \
        -k \$PANORAMA_API_KEY \
        -o panorama_files.txt \
        1>panorama-get-files.stdout 2>panorama-get-files.stderr
    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "panorama_files.txt"
    """
}

process PANORAMA_GET_FILE {
    label 'process_low_constant'
    container 'mriffle/panorama-client:1.0.0'
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stdout"
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stderr"
    storeDir "${params.mzml_cache_directory}", pattern: '*.raw'

    input:
        val web_dav_dir_url
        val file_name

    output:
        path(file_name), emit: panorama_file
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
    """
    echo "Downloading ${file_name} from Panorama..."
        ${exec_java_command(task.memory)} \
        -d \
        -w "${web_dav_url}${file_name}" \
        -k \$PANORAMA_API_KEY \
        1>"panorama-get-${file_name}.stdout" 2>"panorama-get-${file_name}.stderr"
    echo "Done!" # Needed for proper exit
    """

    stub:
    """
    touch "file_name"
    """
}
