### PARAMETERS ### 

rule download_graph:
    output:
        file="../resources/graph/chr20.d9.vg"  # Static construction
    params:
        url="https://s3-us-west-2.amazonaws.com/human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.chroms/chr20.d9.vg"
    log:
        "../logs/download/chr20.log"
    threads: 1
    shell:
        """
        curl -o {output.file} {params.url} 2> {log}
        """


# rule download_hifi_reads:
#     output:
#         file="../resources/sequences/{reads}.{ext}"  # Downloaded files go to "resources/indexes/download/"
#     params:
#         url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.file)
#     log:
#         "../logs/download/{reads}_{ext}.log"
#     threads: 1
#     shell:
#         """
#         curl -o {output.file} {params.url}
#         """

