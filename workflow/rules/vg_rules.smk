### HIFI READS ALINGMENT ### 

rule vg_giraffe_lr_gaf:
    output:
        alignment="../results/alignment/{file}-{region_id}/{sample_id}/{reads_file}.gaf.zst"
    input:
        graph_gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz",
        distance_index="../results/graph/index_giraffe/{file}-{region_id}.dist",
        minimizer_index="../results/graph/index_giraffe/{file}-{region_id}.min",
        hifi_sequence="../resources/sequences/{sample_id}/{reads_file}.fastq"
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "../benchmarks/vg_giraffe_lr/{file}-{region_id}/{sample_id}/{reads_file}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "../logs/vg/giraffe_lr/{file}-{region_id}/{sample_id}/{reads_file}.log"
    threads: workflow.cores
    shell:
        """
        (vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --minimizer-name {input.minimizer_index} --parameter-preset hifi --fastq-in {input.hifi_sequence} --output-format gaf --named-coordinates 2> {log})| scripts/process_out.awk | zstd > {output.alignment}
        """


### GIRAFFE WORKFLOW FILE GENERATION ### 

rule vg_autoindex:
    output:
        index="../results/graph/index_giraffe/{file}-{region_id}.dist",
        minimizer_index="../results/graph/index_giraffe/{file}-{region_id}.min",
        graph_gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz"
    input:
        gfa="../results/graph/gfa/{file}-{region_id}.gfa"
    log:
        "../logs/vg/autoindex/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --target-mem 100 --threads {threads} --prefix ../results/graph/index_giraffe/{wildcards.file}-{wildcards.region_id} --gfa {input.gfa} 2> {log}  2>&1")

### SNARL FILES GENERATION ### 
