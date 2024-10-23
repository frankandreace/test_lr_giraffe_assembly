### HIFI READS ALINGMENT ### 

rule vg_giraffe_lr_gaf:
    output:
        gaf="../results/alignment/{reads_file}_{file}.gaf"
    input:
        graph_gbz="../results/graph/index/{file}.giraffe.gbz",
        distance_index="../results/graph/index/{file}.dist",
        minimizer_index="../results/graph/index/{file}.min",
        hifi_sequence="../resources/sequences/{reads_file}.fastq"
    # params:
    #     url=lambda wildcards: next(entry['url'] for entry in config['urls'] if entry['output'] == wildcards.output)
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "../benchmarks/vg_giraffe_lr_{reads_file}_{file}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "../logs/vg_giraffe_lr_{reads_file}_{file}.log"
    threads: workflow.cores
    shell:
        """
        vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --minimizer-name {input.minimizer_index} --parameter-preset hifi --fastq-in {input.hifi_sequence} --output-format gaf > {output.gaf}
        """


### GRAPH AND INDEX BUILD FROM .VG GRAPH ### 

rule vg_autoindex:
    output:
        index="../results/graph/index/{file}.dist",
        minimizer_index="../results/graph/index/{file}.min",
        graph_gbz="../results/graph/index/{file}.giraffe.gbz"
    input:
        gfa="../resources/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/autoindex/{file}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --target-mem 100 --threads {threads} --prefix ../results/graph/index/{wildcards.file} --gfa {input.gfa} > {log}  2>&1")