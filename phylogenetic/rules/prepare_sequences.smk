"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

REQUIRED INPUTS:

    metadata    = data/metadata.tsv
    sequences   = data/sequences.fasta
    reference   = ../shared/reference.fasta

OUTPUTS:

    prepared_sequences = results/prepared_sequences.fasta

This part of the workflow usually includes the following steps:

    - augur index
    - augur filter
    - augur align
    - augur mask

See Augur's usage docs for these commands for more details.
"""

#rule download:
#    """Downloading sequences and metadata from data.nextstrain.org"""
#    output:
#        sequences = "data/sequences.fasta.zst",
#        metadata = "data/metadata.tsv.zst"
#    params:
#        sequences_url = config["sequences_url"],
#        metadata_url = config["metadata_url"],
#    shell:
#        """
#        curl -fsSL --compressed {params.sequences_url:q} --output {output.sequences}
#        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
#        """
#
#rule decompress:
#    """Decompressing sequences and metadata"""
#    input:
#        sequences = "data/sequences.fasta.zst",
#        metadata = "data/metadata.tsv.zst"
#    output:
#        sequences = "data/sequences.fasta",
#        metadata = "data/metadata.tsv"
#    shell:
#        """
#        zstd -d -c {input.sequences} > {output.sequences}
#        zstd -d -c {input.metadata} > {output.metadata}
#        """

rule filter:
    """
    Basic filter
    """
    input:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv",
        exclude = "defaults/exclude.txt",
    output:
        sequences = "results/filtered.fasta"
    params:
        params='--min-length 8000',
        metadata_id_columns='accession'
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.metadata_id_columns} \
            --exclude {input.exclude} \
            --output {output.sequences} \
            {params.params}
        """

rule align:
    """
    Aligning sequences to {input.reference}
      - filling gaps with N
    """
    input:
        sequences = "results/filtered.fasta",
    output:
        alignment = "results/aligned.fasta",
    params:
        reference = 'NC_001437',
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-name {params.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference
        """
