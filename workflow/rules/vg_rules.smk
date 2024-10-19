### HIFI READS ALINGMENT ### 

rule vg_giraffe_lr_gaf:
    output:
        gaf="../results/alignment/{reads_file}.gaf"
    input:
        graph_gbz=
        distance_index=
        minimizer_index=
        hifi_sequence="{reads_file}.fastq"
    # params:
    #     url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.output)
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "results/benchmarks/vg_giraffe_lr_{sequence}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "results/logs/vg_giraffe_lr_{sequence}.log"
    threads: workflow.cores
    shell:
        """
        vg giraffe --gbz-name graph.gbz --threads {threads} --dist-name graph.dist --minimizer-name graph.min --parameter-preset hifi --fastq-in {reads_file}.fastq  --output-format gaf > {reads_file}.gaf
        """


### GRAPH AND INDEX BUILD FROM .VG GRAPH ### 

rule vg_autoindex:
    output:
        index="../results/graph/index/{file}.gbz"
    input:
        gfa="../results/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/build_distance_index/{file}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --threads {threads} --prefix ../results/graph/index/ --gfa {input.gfa}")