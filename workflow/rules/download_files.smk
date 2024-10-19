### PARAMETERS ### 

rule download_graph:
    output:
        file="../resources/graph/{file}.{ext}"  # Static construction
    params:
        url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.file)
    log:
        "../logs/download/{file}_{ext}.log"
    threads: 1
    shell:
        """
        curl -o {output.file} {params.url}
        """


rule download_hifi_reads:
    output:
        file="../resources/sequences/{reads}.{ext}"  # Downloaded files go to "resources/indexes/download/"
    params:
        url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.file)
    log:
        "../logs/download/{reads}_{ext}.log"
    threads: 1
    shell:
        """
        curl -o {output.file} {params.url}
        """

