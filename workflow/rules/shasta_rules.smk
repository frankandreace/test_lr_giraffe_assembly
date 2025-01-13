
rule shasta_hifi:
    output:
        graph="../results/graph/index/{file}-{region_id}.vg",
    input:
        gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz"
    log:
        "../logs/vg/convert_gbz_to_vg/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("shasta --input 1500/m6401-onso/m64012-190920-173625.Q20.1500.selected.fastq --config m840-revio.conf --anchors 1500/m6401-onso/m6401.anchors.json --assemblyDirectory shasta_test 2> {log}")

rule shasta_ont:
    output:
        graph="../results/graph/index/{file}-{region_id}.vg",
    input:
        gbz="../results/graph/index_giraffe/{file}-{region_id}.giraffe.gbz"
    log:
        "../logs/vg/convert_gbz_to_vg/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("shasta --input 1500/m6401-onso/m64012-190920-173625.Q20.1500.selected.fastq --config m840-revio.conf --anchors 1500/m6401-onso/m6401.anchors.json --assemblyDirectory shasta_test 2> {log}")

