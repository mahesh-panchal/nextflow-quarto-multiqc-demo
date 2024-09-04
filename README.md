# Nextflow Quarto MultiQC workflow

Making custom Quarto documents with Multiqc components from Nextflow output (it could
be outputs from anything, e.g. scripts or tools, or other workflow managers).

> [!NOTE]  
> Before MultiQC 1.22, one needed to create custom panels and include them into
> MultiQC which is what v1.0 of this repository demonstrates. This updated version
> explores using MultiQC as a python library in a Quarto document.

> [!IMPORTANT]
> This is work in progress.

## Usage

In Gitpod:

```
pixi run nextflow
pixi run quarto render docs/multiqc_report/ -P log_path:$PWD/results
```

## Background

MultiQC supports a lot of tools, but not all. Since it's designed primarily for
summaries of large sets of samples, this means that some tools have a hard time getting
plugins since you're only interested in a few plots. While MultiQC supports custom content,
sets of images are not really supported well. Quarto is a flexible publishing tool
that lets you use most languages to process inputs and lay them out as you want.
As a result, you can do things like create tabbed panels per sample and then include
this html as custom content in MultiQC.
