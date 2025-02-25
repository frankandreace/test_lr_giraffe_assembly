### HIFI READS ALINGMENT ### 
wildcard_constraints:
    ont_sample_id="[^/]*ont[^/]*", 
    hifi_sample_id="[^/]*m[^/]*"

# ruleorder: vg_giraffe_hifi_gaf > vg_giraffe_gaf_r10

# rule vg_giraffe_r10_gaf:
#     output:
#         alignment="../results/alignment/{file}-{region_id}/{ont_sample_id}/{reads_file}.gaf.zst"
#     input:
#         graph_gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz",
#         distance_index="../results/graph/index_giraffe/{file}-{region_id}.dist",
#         minimizer_index="../results/graph/index_giraffe/{file}-{region_id}.min",
#         hifi_sequence="../resources/sequences/{ont_sample_id}/{reads_file}.fastq.gz"
#     benchmark:
#         # Directly use the {output} wildcard as part of the formatted string
#         "../benchmarks/vg_giraffe_lr/{file}-{region_id}/{ont_sample_id}/{reads_file}.benchmark.txt"
#     log:
#         # Also use {output} for logging file
#         "../logs/vg/giraffe_lr/{file}-{region_id}/{ont_sample_id}/{reads_file}.log"
#     threads:16  #workflow.cores
#     shell:
#         """
#         (vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --minimizer-name {input.minimizer_index} --parameter-preset r10 --fastq-in {input.hifi_sequence} --output-format gaf 2> {log})| zstd > {output.alignment}
#         """
# #scripts/process_out.awk |

# rule vg_giraffe_lr_gaf:
#     output:
#         alignment="../results/alignment/{file}-{region_id}/{hifi_sample_id}/{reads_file}.gaf.zst"
#     input:
#         graph_gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz",
#         distance_index="../results/graph/index_giraffe/{file}-{region_id}.dist",
#         minimizer_index="../results/graph/index_giraffe/{file}-{region_id}.min",
#         hifi_sequence="../resources/sequences/{hifi_sample_id}/{reads_file}.fastq.gz"
#     benchmark:
#         # Directly use the {output} wildcard as part of the formatted string
#         "../benchmarks/vg_giraffe_lr/{file}-{region_id}/{hifi_sample_id}/{reads_file}.benchmark.txt"
#     log:
#         # Also use {output} for logging file
#         "../logs/vg/giraffe_lr/{file}-{region_id}/{hifi_sample_id}/{reads_file}.log"
#     threads: workflow.cores
#     shell:
#         """
#         vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --minimizer-name {input.minimizer_index} --parameter-preset hifi --fastq-in {input.hifi_sequence} --output-format gaf 2> {log} | zstd > {output.alignment}
#         """
#--named-coordinates

rule vg_giraffe_hifi_gaf:
    output:
        alignment="../results/alignment/full/{file}/{hifi_sample_id}/{reads_file}.gaf.gz"
    input:
        graph_gbz="../results/graph/index_giraffe/full/{file}.gbz",
        distance_index="../results/graph/index_giraffe/full/{file}.dist",
        #minimizer_index="../results/graph/index_giraffe/full/{file}.min", #--minimizer-name {input.minimizer_index}
        hifi_sequence="../resources/sequences/{hifi_sample_id}/{reads_file}.fastq.gz"
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "../benchmarks/vg_giraffe_lr/{file}/{hifi_sample_id}/{reads_file}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "../logs/vg/giraffe_lr/{file}/{hifi_sample_id}/{reads_file}.log"
    threads: workflow.cores
    shell:
        """
        /usr/bin/time -v vg giraffe --gbz-name {input.graph_gbz} --dist-name {input.distance_index} --parameter-preset hifi --fastq-in {input.hifi_sequence} --output-format gaf --threads {threads} --progress 2> {log} | gzip > {output.alignment}
        """

# ONT VG GIRAFFE LONG READS ALINGMENT 
rule vg_giraffe_gaf_r10:
    output:
        alignment="../results/alignment/full/{file}/{ont_sample_id}/{reads_file}.gaf.gz"
    input:
        graph_gbz="../results/graph/index_giraffe/full/{file}.gbz",
        distance_index="../results/graph/index_giraffe/full/{file}.dist",
        #minimizer_index="../results/graph/index_giraffe/full/{file}.min", #--minimizer-name {input.minimizer_index}
        ont_sequence="../resources/sequences/{ont_sample_id}/{reads_file}.fastq.gz"
    benchmark:
        # Directly use the {output} wildcard as part of the formatted string
        "../benchmarks/vg_giraffe_lr/{file}/{ont_sample_id}/{reads_file}.benchmark.txt"
    log:
        # Also use {output} for logging file
        "../logs/vg/giraffe_lr/{file}/{ont_sample_id}/{reads_file}.log"
    threads: workflow.cores
    shell:
        """
        /usr/bin/time -v vg giraffe --gbz-name {input.graph_gbz} --threads {threads} --dist-name {input.distance_index} --parameter-preset r10 --fastq-in {input.ont_sequence} --output-format gaf --progress 2> {log} | gzip > {output.alignment}
        """


### GIRAFFE WORKFLOW FILE GENERATION ### 

rule vg_autoindex:
    output:
        index="../results/graph/index_giraffe/{file}-{region_id}.dist",
        minimizer_index="../results/graph/index_giraffe/{file}-{region_id}.min",
        graph_gbz="../results/graph/index_giraffe/{file}-{region_id}.gbz"
    input:
        gfa="../results/graph/gfa/{file}-{region_id}.gfa"
    log:
        "../logs/vg/autoindex/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("vg autoindex --workflow giraffe --target-mem 100 --threads {threads} --prefix ../results/graph/index_giraffe/{wildcards.file}-{wildcards.region_id} --gfa {input.gfa} 2> {log}  2>&1")

rule vg_autoindex_full_chr:
    output:
        index="../results/graph/index_giraffe/full/{file}.dist",
        minimizer_index="../results/graph/index_giraffe/full/{file}.min",
        graph_gbz="../results/graph/index_giraffe/full/{file}.gbz"
    input:
        gfa="../results/graph/full_gfa/{file}.full.gfa"
    log:
        "../logs/vg/autoindex/{file}.log"
    threads: 16
    run:
        shell("vg autoindex --workflow giraffe --target-mem 100 --threads {threads} --prefix ../results/graph/index_giraffe/full/{wildcards.file} --gfa {input.gfa} 2> {log}  2>&1")

### SNARL FILES GENERATION ### 
