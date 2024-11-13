wildcard_constraints:
    file="[^/]+",  # Matches any string not containing '/'
    reads_file="[^/]+",  # Matches any string not containing '/'
    al_file="[^/]+",  # Matches any string not containing '/'
    sample_id="[^/]+"  # Matches any string not containing '/'

rule parse_gaf:
    output:
        file="../results/alignment/{al_file}.processed.gaf" 
    input:
        gaf="../results/alignment/{al_file}.gaf.zst"
    log:
        "../logs/gaf_parsing/{al_file}.log"
    shell:
        """
        python3 scripts/parse_gaf.py {input.gaf} > {output.file} 2> {log}
        """

rule verify_anchors_correctness:
    output:
        file="../results/anchor_correctness/{file}/{sample_id}.txt"  
    input:
        anchors="../results/anchors/{file}/{sample_id}.anchors.json",
        hifi_sequence="../resources/sequences/{reads_file}.fastq"
    shell:
        """
        vg_anchor verify-output --anchors {input.anchors} --fastq {input.hifi_sequence} 2> {output.file}
        """

rule generate_anchors_dictionary:
    output:
        anchors_dictionary="../results/anchor_dictionary/{wildcards.file}.pkl"
    input:
        distance_index="../results/graph/index/{wildcards.file}.dist",
        packed_graph="../results/graph/index/{wildcards.file}.vg"

    log:
        "../logs/gaf_parsing/{wildcards.file}.log"
    shell:
        """
        vg_anchor build --graph {input.packed_graph} --index {input.distance_index} --output-prefix ../results/anchor_dictionary/{wildcards.file} 2> {log}
        """

rule get_anchors_from_gaf:
    output:
        anchors="../results/anchors/{file}/{sample_id}.anchors.json"
    input:
        anchors_dictionary="../results/anchor_dictionary/{file}.pkl",
        alignment="../results/alignment/{file}/{sample_id}/alignments-combined.processed.gaf",
        packed_graph="../results/graph/index/{file}.vg"

    log:
        "../logs/gaf_parsing/{file}.{sample_id}.log"
    shell:
        """
        vg_anchor get-anchors --dictionary {input.anchors_dictionary} --graph {input.packed_graph} --alignment {input.alignment} --output {output.anchors} 2> {log}
        """

rule concatenate_files:
    input:
        files = expand("../results/alignment/{file}/{sample_id}/processed/{sequence}.gaf",sequence=config["SEQUENCES"], file=config["FILES"], sample_id=config["SAMPLE_IDS"])
    output:
        combined = "../results/alignment/{file}/{sample_id}/alignments-combined.processed.gaf"
    shell:
        """
        cat {input.files} > {output.combined}
        """