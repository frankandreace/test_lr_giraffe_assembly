### HIFI READS ALINGMENT ### 

rule vg_giraffe_lr_gaf:
    output:
        gaf="../results/alignment/{reads_file}.gaf"
    input:
        # graph_gbz=
        # distance_index=
        # minimizer_index=
        hifi_sequence="{reads_file}.fastq"
    # params:
    #     url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.output)
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "..S/benchmarks/vg_giraffe_lr_{reads_file}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "../logs/vg_giraffe_lr_{reads_file}.log"
    threads: workflow.cores
    shell:
        """
        vg giraffe --gbz-name graph.gbz --threads {threads} --dist-name graph.dist --minimizer-name graph.min --parameter-preset hifi --fastq-in {reads_file}.fastq  --output-format gaf > {reads_file}.gaf
        """


### GRAPH AND INDEX BUILD FROM .VG GRAPH ### 

rule vg_autoindex:
    output:
        index="../results/graph/index/chr19_index.dist"
    input:
        gfa="../results/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/autoindex/{file}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --target-mem 25 --threads {threads} --prefix ../results/graph/index/chr19_index --gfa {input.gfa} > {log}  2>&1")