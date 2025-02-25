### PARAMETERS ### 

wildcard_constraints:
    full_file="[^-]+",  # Matches any string not containing '/'
    odgi_file="[^d9-]+",  # Matches any string not containing '/'


def get_region_position(wildcard):
    """
    This function is used to generate the string to give in input to vg chunk to get required find the genomic position
    """
    region = config['REGIONS'][wildcard]
    return f"CHM13#0#{region['chromosome']}:{region['start']}-{region['end']}"

# def get_region_name(wildcards):
#     """
#     This function is used to generate the name of the output subgraph or parsed alignment using the region name.
#     """
#     return wildcards.region_id

### RULES ###

# convert gbz to vg (for Python APIs)
rule vg_gbz_to_vg:
    output:
        graph="../results/graph/index_giraffe/full/{file}.vg",
    input:
        gbz="../results/graph/index_giraffe/full/{file}.gbz"
    log:
        "../logs/vg/convert_gbz_to_vg/{file}.log"
    threads: workflow.cores
    run:
        shell("vg convert --threads {threads} {input.gbz} --packed-out > {output.graph} 2> {log}")

# convert vg to gfa (to visualize the region on Bandage)
rule vg_to_gfa:
    input:
        graph="../results/graph/index_giraffe/full/{file}.vg",
    output:
        gfa="../results/graph/gfa/{file}.gfa"
    log:
        "../logs/vg/convert_vg_to_gfa/{file}.log"
    threads: workflow.cores
    run:
        shell("vg convert --threads {threads} {input.graph} ---gfa-out > {output.gfa} 2> {log}")

# generate the distance index from a packedgraph (.vg)
rule vg_distance_index:
    output:
        index = "../results/graph/index/{file}-{region_id}.dist"
    input:
        graph = "../results/graph/index/{file}-{region_id}.vg"
    log: "../logs/vg/distance_index/{file}_{region_id}.log"
    threads: workflow.cores
    run:
        shell("vg index {input.graph} --threads {threads} --dist-name {output.index} 2> {log}")

# concatenate alignment files into 1 if required
rule concatenate_alignments:
    input:
        files = lambda wildcards: expand("../results/alignment/full/{file}/{sample_id}/{reads_file}.gaf.gz", 
        file=wildcards.file,
        sample_id=wildcards.sample_id,
        reads_file=get_sequences(wildcards.sample_id))
    output:
        combined = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.gaf.gz"
    threads: 1
    run:
        shell("cat {input.files} > {output.combined}")

rule vg_chunk_graph:
    output:
        subgraph="../results/graph/index_giraffe/full/{file}/{region_name}.vg",
    input:
        graph="../results/graph/index_giraffe/full/{file}.gbz",
        snarl = "../results/graph/index_giraffe/full/{file}.snarls"
    params:
        region_id = lambda wildcards: get_region_position(wildcards.region_name)
    log:
        "../logs/vg/chink_graph/{file}_{region_name}.log"
    threads: workflow.cores
    run:
        shell("vg chunk -g -x {input.graph} -p {params.region_id} -S {input.snarl} -O pg --threads {threads} -b {wildcards.region_name} > {output.subgraph} 2> {log}")

rule vg_chunk_reads:
    output:
        chunked_gaf="../results/alignment/full/{file}/{sample_id}/processed/{region_name}/concatenated_alignments.gaf.gz"
    input:
        graph="../results/graph/index_giraffe/full/{file}.gbz",
        sorted_gaf="../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.sorted.gaf.gz",
        snarl = "../results/graph/index_giraffe/full/{file}.snarls",
        tabix_file = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.sorted.gaf.gz.tbi"
    params:
        region_id = lambda wildcards: get_region_position(wildcards.region_name),
    log:
        "../logs/vg/chunk_reads/{file}_{sample_id}_{region_name}.log"
    threads: workflow.cores
    run:
        shell("vg chunk -a {input.sorted_gaf} -F -x {input.graph} -p {params.region_id} -S {input.snarl} --threads {threads} -b {wildcards.region_name} > {output.chunked_gaf} 2> {log}")


rule sort_gaf:
    input:
        gaf_combined = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.gaf.gz"
    output:
        gaf_sorted = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.sorted.gaf.gz"
    log:
        log = "../logs/sort_gaf/{file}_{sample_id}.log"
    threads: workflow.cores
    run:
        shell("vg gamsort -t {threads} -p -G {input.gaf_combined} | bgzip -c > {output.gaf_sorted}")

rule index_sorted_gaf:
    input:
        gaf_sorted = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.sorted.gaf.gz"
    output:
        tabix_file = "../results/alignment/full/{file}/{sample_id}/processed/{sample_id}.sorted.gaf.gz.tbi"
    log: 
        log = "../logs/index_gaf/{file}_{sample_id}.log"
    threads: workflow.cores
    run:
        shell("tabix --threads {threads} -p gaf {input.gaf_sorted} 2> {log.log}")

