### PARAMETERS ### 
def get_region(wildcards):
    region_id = wildcards.region_id
    region = config['regions'][region_id]
    return f"{region['chromosome']}:{region['start']}-{region['end']}"

rule odgi_view:
    output:
        file="../results/graph/gfa/{file}-{region_id}.gfa"
    input:
        file="../results/graph/index/{file}-{region_id}.og"
    log:
        "../logs/odgi_to_gfa/{file}-{region_id}.log"
    threads: workflow.cores
    shell:
        """
        odgi view -i {input.file} -g > {output.file}
        """

rule odgi_extract_region:
    output:
        file="../results/graph/index/{file}-{region_id}.og"
    input:
        file="../resources/graph/{file}.og"
    log:
        "../logs/odgi_to_gfa/{file}-{region_id}.log"
    threads: workflow.cores
    params:
        region = get_region
    shell:
        """
        odgi extract -i {input.file} -o {output.file} -r CHM13#{params.region} -O -t16 -P -c100
        """

rule vg_gfa_to_vg:
    output:
        graph="../results/graph/index/{file}-{region_id}.vg",
    input:
        gfa="../results/graph/gfa/{file}-{region_id}.gfa"
    log:
        "../logs/vg/convert_gfa_to_vg/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("vg convert --threads {threads} --gfa-in {input.gfa} --packed-out > {output.graph} 2> {log}")

rule vg_distance_index:
    output:
        index="../results/graph/index/{file}-{region_id}.dist",
    input:
        graph="../results/graph/index/{file}-{region_id}.vg"
    log:
        "../logs/vg/distance_index/{file}-{region_id}.log"
    threads: workflow.cores
    run:
        shell("vg index {input.graph} --threads {threads} --dist-name {output.index} 2> {log}")