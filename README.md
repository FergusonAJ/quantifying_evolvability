# A template for experiments using MABE2
Now that I've built a few different projects around MABE2, I'm somewhat content with my experiment workflow and pipeline. 
This repo serves as a basis for future projects to build off of. It _should_ be functional currently, but the plan is to continue updating this repo as I continue to refine my processes. 

NOTE: This whole pipeline is built around high performance computing that leverages slurm. 
I provide support for running experiments locally, but that functionality is much less refined. 

## Philosophy
Overall, my goal for this repo and those derived from it has two main points: 
1. **Organization** - When you run an experiment, my goal is for all of your supporting files, job-preparation scripts, analyses, etc. to all live in the one directory (with exceptions, of course)
2. **Reproducibility** - I aim for my science to always be easy to replicate, and with this template I hope yours will be too! This is done via automating as much of the pipeline as possible, and making sure the rest is clearly labeled and easy to run. 

## Using the template
I'm new to this idea of template repo's, but it seems like the GitHub has solid support: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template


## Cloning your new repo
**IMPORTANT**: This repo uses GitHub submodules. These are great, but they can be a pain to download, especially if your submodules have their own submodules (which is the case with MABE2 and Empirical). 

To avoid these issues, make sure you clone _recursively_:

```
git clone <YOUR REPO HERE> --recursive
```
This should download all the submodules automatically. 

If you forget the recursive flag, you'll need to run the following two commands _in every repo that has submodules_ (this one, MABE2, Empirical)
```
git submodule init
git submodule update
```

## Experiment nanming
One of the assumptions I make is that all your experiment directories will follow the naming convention of: 
```
YYYY_MM_DD_ID__experiment_name_here
```
YYYY is the four digit year, MM is the two digit month, DD is the two digit day, and ID is a two-digit identifier of which experiment this is in the day. 
You can then include anything after the double underscore. 

This is done to make random seeds easier. I simply scrape the year, month, day, and id and squish them into a base seed. 
This ensures we don't duplicate seeds between experiments. 

Note that you can nest your experiments in subdirectories. 
When you then run the experiment, the same directory structure will be copied to your scratch. 

## Customizing your repo
It's important to note that this repo currently links _my_ fork of MABE2 (because I'll probably use it the most). 
Two things about this: 
1. You can point the MABE2 submodule to another fork or branch.
2. I use ssh keys and my submodules reflect that. If you run into issues with those keys, you may want to switch to https. 
