# Nextflow Quarto MultiQC workflow

Proof of concept to include Quarto documents as sections in MultiQC, wrapped up in
Nextflow.

## Background

MultiQC supports a lot of tools, but not all. Since it's designed primarily for
summaries of large sets of samples, this means that some tools have a hard time getting
plugins since you're only interested in a few plots. While MultiQC supports custom content,
sets of images are not really supported well. Quarto is a flexible publishing tool
that lets you use most languages to process inputs and lay them out as you want.
As a result, you can do things like create tabbed panels per sample and then include
this html as custom content in MultiQC.
