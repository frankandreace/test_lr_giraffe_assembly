### PARAMETERS ### 

rule download_graph:
    output:
        file="../resources/full_graph/{graph_name}.full.og"  # Static construction
    params:
        url="s3://human-pangenomics/pangenomes/freeze/freeze1/minigraph-cactus/hprc-v1.1-mc-chm13/hprc-v1.1-mc-chm13.chroms/{graph_name}.full.og",
        #foder="../resources/graph/"
    log:
        "../logs/download/{graph_name}.log"
    threads: 1
    shell:
        """
        aws s3 cp --no-sign-request {params.url} {output.file} 2> {log}
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

