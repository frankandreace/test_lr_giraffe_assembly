### PARAMETERS ### 

rule download_data:
    output:
        lambda wildcards: wildcards.output
    params:
        url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.output)
    benchmark:
        "benchmarks/ggcat_index.tsv"
    log:
        "logs/ggcat_index.log"
    threads: workflow.cores
    shell:
        """
        mkdir -p data
        curl -o {output} {params.url}
        """
