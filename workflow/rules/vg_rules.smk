### HIFI READS ALINGMENT ### 

rule vg_giraffe_lr_gaf:
    output:
        gaf="../results/alignment/{reads_file}_{file}.gaf"
    input:
        graph_gbz="../results/graph/index_giraffe/{file}.giraffe.gbz",
        distance_index="../results/graph/index_giraffe/{file}.dist",
        minimizer_index="../results/graph/index_giraffe/{file}.min",
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
        vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --minimizer-name {input.minimizer_index} --parameter-preset hifi --fastq-in {input.hifi_sequence} --output-format gaf --named-coordinates > {output.gaf}
        """


### GIRAFFE WORKFLOW FILE GENERATION ### 

rule vg_autoindex:
    output:
        index="../results/graph/index_giraffe/{file}.dist",
        minimizer_index="../results/graph/index_giraffe/{file}.min",
        graph_gbz="../results/graph/index_giraffe/{file}.giraffe.gbz"
    input:
        gfa="../resources/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/autoindex/{file}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --target-mem 100 --threads {threads} --prefix ../results/graph/index_giraffe/{wildcards.file} --gfa {input.gfa} 2> {log}  2>&1")


### SNARL FILES GENERATION ### 

rule vg_convert_gfa_to_vg:
    output:
        graph="../results/graph/index/{file}.vg",
    input:
        gfa="../resources/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/convert_gfa_to_vg/{file}.log"
    threads: workflow.cores
    run:
        shell("vg convert --threads {threads} --gfa-in {input.gfa} --packed-out > {output.graph} 2> {log}")

rule vg_distance_index:
    output:
        index="../results/graph/index/{file}.dist",
    input:
        graph="../results/graph/index/{file}.vg"
    log:
        "../logs/vg/distance_index/{file}.log"
    threads: workflow.cores
    run:
        shell("vg index {input.graph} --threads {threads} --dist-name {output.index} 2> {log}")