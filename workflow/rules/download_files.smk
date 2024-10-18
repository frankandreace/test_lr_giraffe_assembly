### PARAMETERS ### 

rule download_data:
    output:
        file="{output}"  # The wildcard {output} represents the file path from config
    params:
        url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.output)
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "results/benchmarks/download_{output}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "results/logs/download_{output}.log"
    threads: 1  # Set the appropriate number of threads, curl usually uses 1 thread
    shell:
        """
        curl -o {output.file} {params.url}
        """