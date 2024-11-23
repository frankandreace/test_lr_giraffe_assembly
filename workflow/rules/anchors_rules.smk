def get_sequences(sample_id):
    return config["SEQUENCES"][sample_id]

def get_all_sequences(wildcards):
    return expand("../resources/sequences/{sample_id}/{reads_file}.fastq.gz",
                  sample_id=wildcards.sample_id,
                  reads_file=get_sequences(wildcards.sample_id))


wildcard_constraints:
    file="[^/]+",  # Matches any string not containing '/'
    reads_file="[^/]+",  # Matches any string not containing '/'
    al_file="[^/]+",  # Matches any string not containing '/'
    sample_id="[^/]+"  # Matches any string not containing '/'

rule parse_gaf:
    output:
        file="../results/alignment/{file}-{region_id}/{sample_id}/{reads_file}.processed.gaf" 
    input:
        gaf="../results/alignment/{file}-{region_id}/{sample_id}/{reads_file}.gaf.zst"
    log:
        "../logs/gaf_parsing/{file}-{region_id}/{sample_id}/{reads_file}.log"
    shell:
        """
        python3 scripts/parse_gaf.py {input.gaf} > {output.file} 2> {log}
        """

rule verify_anchors_correctness:
    output:
        file="../results/anchor_correctness/{file}-{region_id}/{sample_id}.txt",
        out_fastq="../resources/sequences/{sample_id}/{file}-{region_id}.selected.fastq"  
    input:
        anchors="../results/anchors/{file}-{region_id}/{sample_id}.anchors.json",
        hifi_sequences=get_all_sequences
    log:
        "../logs/achor_correctnesss/{file}-{region_id}/{sample_id}.log"
    shell:
        """
        vg_anchor verify-output --anchors {input.anchors} {input.hifi_sequences} > {output.file} 2> {log}
        """

rule generate_anchors_dictionary:
    output:
        anchors_dictionary="../results/anchor_dictionary/{file}-{region_id}.pkl"
    input:
        distance_index="../results/graph/index/{file}-{region_id}.dist",
        packed_graph="../results/graph/index/{file}-{region_id}.vg"

    log:
        "../logs/generate_anchors/{file}-{region_id}.log"
    shell:
        """
        vg_anchor build --graph {input.packed_graph} --index {input.distance_index} --output-prefix ../results/anchor_dictionary/{wildcards.file}-{wildcards.region_id} 2> {log}
        """

rule get_anchors_from_gaf:
    output:
        anchors="../results/anchors/{file}-{region_id}/{sample_id}.anchors.json"
    input:
        anchors_dictionary="../results/anchor_dictionary/{file}-{region_id}.pkl",
        alignment="../results/alignment/{file}-{region_id}/{sample_id}/alignments-combined.processed.gaf",
        packed_graph="../results/graph/index/{file}-{region_id}.vg"

    log:
        "../logs/gaf_parsing/{file}-{region_id}/{sample_id}.log"
    shell:
        """
        vg_anchor get-anchors --dictionary {input.anchors_dictionary} --graph {input.packed_graph} --alignment {input.alignment} --output {output.anchors} 2> {log}
        """

rule concatenate_files:
    input:
        files = lambda wildcards: expand("../results/alignment/{file}-{region_id}/{sample_id}/{reads_file}.processed.gaf", 
                                        file=wildcards.file,
                                        region_id=wildcards.region_id,
                                        sample_id=wildcards.sample_id,
                                        reads_file=get_sequences(wildcards.sample_id))
    output:
        combined = "../results/alignment/{file}-{region_id}/{sample_id}/alignments-combined.processed.gaf"
    shell:
        """
        cat {input.files} > {output.combined}
        """