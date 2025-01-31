if config["datatype"] == "SampleData[PairedEndSequencesWithQuality]":

    rule kraken_analysis:
        input:
            db="resources/minikraken2_v2_8GB_201904_UPDATE/",
            read1="data/{date}/{sample}_L001_R1_001.fastq.gz",
            read2="data/{date}/{sample}_L001_R2_001.fastq.gz",
        output:
            report="results/{date}/out/kraken/{sample}.kreport2",
        resources:
            mem_mb=100,
        threads: 1
        params:
            threads=1,
        log:
            "logs/{date}/kraken/{sample}.log",
        conda:
            "../envs/python.yaml"
        shell:
            "(kraken2 --db {input.db} --memory-mapping --threads {params.threads} --paired --use-names --report {output.report} {input.read1} {input.read2}) 2> {log}"


if config["datatype"] == "SampleData[SequencesWithQuality]":

    rule kraken_analysis:
        input:
            db="resources/minikraken2_v2_8GB_201904_UPDATE/",
            read="data/{date}/{sample}_L001_R1_001.fastq.gz",
        output:
            report="results/{date}/out/kraken/{sample}.kreport2",
        resources:
            mem_mb=100,
        threads: 1
        params:
            threads=1,
        log:
            "logs/{date}/kraken/{sample}.log",
        conda:
            "../envs/python.yaml"
        shell:
            "(kraken2 --db {input.db} --memory-mapping --threads {params.threads} --use-names --report {output.report} {input.read}) 2> {log}"


rule fastqc:
    input:
        "data/{date}/{names}",
    output:
        html="results/{date}/out/fastqc/{names}.html",
        zip="results/{date}/out/fastqc/{names}_fastqc.zip",
    log:
        "logs/{date}/fastqc/{names}.log",
    threads: 8
    wrapper:
        "v1.3.1/bio/fastqc"


rule multiqc_report:
    input:
        expand(
            "results/{{date}}/out/fastqc/{names}_fastqc.zip",
            names=get_filenames(),
        ),
        expand(
            "results/{{date}}/out/kraken/{sample}.kreport2",
            sample=get_reads_for_kraken(),
        ),
    output:
        report(
            "results/{date}/visual/report/multiqc.html",
            caption="../report/multiqc.rst",
            htmlindex="multiqc.htm",
            category="4. Qualitycontrol",
        ),
    log:
        "logs/{date}/multiqc.log",
    wrapper:
        "v1.23.3/bio/multiqc"
