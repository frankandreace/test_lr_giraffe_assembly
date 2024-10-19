### PARAMETERS ### 

rule odgi_to_gfa:
    output:
        file="../results/graph/gfa/{file}.gfa"  # Static construction
    input:
        file="../resources/graph/{file}.og"
    log:
        "../logs/odgi_to_gfa/{file}.log"
    threads: workflow.cores
    shell:
        """
        odgi view --threads {threads} -i {input.file} -g > {output.file}
        """
