rule shasta_assemblies:
    output:
        assembly="../results/assemblies/{file}/{sample_id}/{region_id}.fasta",
    input:
        selected_reads="../resources/sequences/{sample_id}/{file}-{region_id}.selected.fastq",
        anchors="../results/anchors/{file}-{region_id}/{sample_id}.anchors.json"
    log:
        "../logs/shasta/{file}-{region_id}/{sample_id}/shasta_assembly.log"
    threads: workflow.cores
    run:
        shell("shasta --input {input.selected_reads} --config ../resources/shasta/{wildcards.sample_id}.shasta.conf --anchors {input.anchors} --assembly-directory ../results/shasta_assemblies/{file}/{sample_id} --threads {threads}")
