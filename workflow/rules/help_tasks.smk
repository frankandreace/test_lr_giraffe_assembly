### PARAMETERS ### 

rule vg_to_gfa:
    output:
        file="../results/graph/gfa/{file}.gfa"  # Static construction
    input:
        file="../results/graph/{file}.vg"
    log:
        "../logs/vg_to_gfa/{file}.log"
    threads: workflow.cores
    shell:
        """
        vg convert {input.file} -f > {output.file} 2> {log}
        """

rule vg_extract_region:
    output:
        file="../results/graph/{file}.100K.vg"  # Static construction
    input:
        file="../resources/graph/{file}.d9.vg"
    log:
        "../logs/odgi_to_gfa/{file}-100K.log"
    threads: workflow.cores
    shell:
        """
        vg chunk -x {input.file} -p CHM13#chr20:5000-105000 -c100 > {output.file} 2> {log}
        """

rule vg_gfa_to_vg:
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