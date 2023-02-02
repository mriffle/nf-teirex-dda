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
        secret 'PANORAMA_API_KEY'

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

process PANORAMA_GET_FASTA {
    label 'process_low_constant'
    container 'mriffle/panorama-client:1.0.0'
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stdout"
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stderr"

    input:
        val web_dav_dir_url
        secret 'PANORAMA_API_KEY'

    output:
        path("${file(web_dav_dir_url).name}"), emit: panorama_file
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
        file_name = file(web_dav_dir_url).name
        """
        echo "Downloading ${file_name} from Panorama..."
            ${exec_java_command(task.memory)} \
            -d \
            -w "${web_dav_dir_url}" \
            -k \$PANORAMA_API_KEY \
            1>"panorama-get-${file_name}.stdout" 2>"panorama-get-${file_name}.stderr"
        echo "Done!" # Needed for proper exit
        """

    stub:
    """
    touch "{$file(web_dav_dir_url).name}"
    """
}

process PANORAMA_GET_COMET_PARAMS {
    label 'process_low_constant'
    container 'mriffle/panorama-client:1.0.0'
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stdout"
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stderr"

    input:
        val web_dav_dir_url
        secret 'PANORAMA_API_KEY'

    output:
        path("${file(web_dav_dir_url).name}"), emit: panorama_file
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
        file_name = file(web_dav_dir_url).name
        """
        echo "Downloading ${file_name} from Panorama..."
            ${exec_java_command(task.memory)} \
            -d \
            -w "${web_dav_dir_url}" \
            -k \$PANORAMA_API_KEY \
            1>"panorama-get-${file_name}.stdout" 2>"panorama-get-${file_name}.stderr"
        echo "Done!" # Needed for proper exit
        """

    stub:
    """
    touch "{$file(web_dav_dir_url).name}"
    """
}

process PANORAMA_GET_RAW_FILE {
    label 'process_low_constant'
    container 'mriffle/panorama-client:1.0.0'
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stdout"
    publishDir "${params.result_dir}/panorama", failOnError: true, mode: 'copy', pattern: "*.stderr"
    storeDir "${params.panorama_cache_directory}"

    input:
        val raw_file_ch
        val web_dav_dir_url
        secret 'PANORAMA_API_KEY'

    output:
        path("${raw_file_ch}"), emit: panorama_file
        path("*.stdout"), emit: stdout
        path("*.stderr"), emit: stderr

    script:
        """
        echo "Downloading ${raw_file_ch} from Panorama..."
            ${exec_java_command(task.memory)} \
            -d \
            -w "${web_dav_dir_url}${raw_file_ch}" \
            -k \$PANORAMA_API_KEY \
            1>"panorama-get-${raw_file_ch}.stdout" 2>"panorama-get-${raw_file_ch}.stderr"
        echo "Done!" # Needed for proper exit
        """

    stub:
    """
    touch "{$raw_file_ch}"
    """
}