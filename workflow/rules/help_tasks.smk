### PARAMETERS ### 

wildcard_constraints:
    full_file="[^-]+",  # Matches any string not containing '/'
    odgi_file="[^d9-]+",  # Matches any string not containing '/'

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

rule odgi_view_entire:
    output:
        file="../results/graph/full_gfa/{odgi_file}.full.gfa"
    input:
        file="../resources/full_graph/{odgi_file}.full.og"
    log:
        "../logs/odgi_to_gfa/entire/{odgi_file}.log"
    threads: workflow.cores
    shell:
        """
        odgi view -i {input.file} -g > {output.file}
        """

rule odgi_extract_region:
    output:
        file="../results/graph/index/{odgi_file}-{region_id}.og"
    input:
        file="../resources/graph/{odgi_file}.og"
    log:
        "../logs/odgi_to_gfa/{odgi_file}-{region_id}.log"
    threads: workflow.cores
    params:
        region = get_region
    shell:
        """
        odgi extract -i {input.file} -o {output.file} -r CHM13#{params.region} -O -t16 -P -c100
        """
#../scripts/extract_region {input.file} {output.file} {params.region}
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

rule vg_to_gfa:
    input:
        graph="../resources/full_graph/{file}.vg",
    output:
        gfa="../results/graph/full_gfa/{file}.gfa"
    log:
        "../logs/vg/convert_vg_to_gfa/{file}.log"
    threads: workflow.cores
    run:
        shell("vg convert --threads {threads} {input.graph} ---gfa-out > {output.gfa} 2> {log}")

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