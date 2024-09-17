# Nextflow Quarto MultiQC workflow

Making custom Quarto documents with Multiqc components from Nextflow output (it could
be outputs from anything, e.g. scripts or tools, or other workflow managers).

> [!NOTE]  
> Before MultiQC 1.22, one needed to create custom panels and include them into
> MultiQC which is what v1.0 of this repository demonstrates. This updated version
> explores using MultiQC as a python library in a Quarto document.

## Usage

The Quarto report is generated within a Nextflow process.

The Quarto report also demonstrates using conditional sections. This is
achieved by copying the `params.yml` as `_quarto.yml` and then using the
`when-meta`/`unless-meta` attributes. 

> [!WARNING]
> Hiding sections with `when-meta`/`unless-meta` does not stop the computations
> from running, and so you should still check the `params` before executing
> a code cell.

### Gitpod

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/mahesh-panchal/nextflow-quarto-multiqc-demo)

```bash
pixi run nextflow
```

### Locally

Have `pixi` and `git` available in your path.

```bash
git clone https://github.com/mahesh-panchal/nextflow-quarto-multiqc-demo.git
cd nextflow-quarto-multiqc-demo
pixi run nextflow
```

## Background

MultiQC supports a lot of tools, but not all. Since it's designed primarily for
summaries of large sets of samples, this means that some tools have a hard time getting
plugins since you're only interested in a few plots. While MultiQC supports custom content,
including single images, sets of images are not really supported. Quarto is a flexible publishing tool
that lets you use most languages to process inputs and lay them out as you want.
As a result, you can do things like create tabbed panels per sample and then include
this html as custom content in MultiQC.

## Implementation description

> [!WARNING]
> Work in progress. I'm still trying to understand best practice for combining profiles,
> metadata, parameters, and how it might work with MultiQC.

Notebooks that make up a Quarto document can be individually rendered in separate environments.
Using `execute: { freeze: auto }`, means the cache can be copied between Nextflow processes
and used in rendering a master document. Sections for inclusion can likely be controlled using
a `_metadata.yml` file.
