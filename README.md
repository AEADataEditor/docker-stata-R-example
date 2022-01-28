# A Stata + R Docker Project

We simply demonstrate how you can combine Stata with R into a single Docker image.

Note that this could also include installing Pandoc or LaTeX, if needed, for Stata.

Alternatively, one could use a JupyterLab setup, install the `stata_kernel`, and then copy in the Stata binaries.

## Setting up

- Edit the [`init.config.txt`](init.config.txt) to have the desired values for the Docker image you will create:

```{bash}
VERSION=17
# the TAG can be anything, but could be today's date
TAG=$(date +%F) 
MYHUBID=larsvilhuber
MYIMG=${PWD##*/}
```

where

- `VERSION` is the Stata version you want to use (this might be ignored right now)
- `TAG` is the Docker tag you will be using - could be "latest", could be a specific name. Has to be lower-case.
- `MYHUBID` is presumably your Docker login
- `MYIMG` is the name you want to give the Docker image you are creating. By default, it presumes that it will be the same name as the Git repository.

- Edit the [`Dockerfile`](Dockerfile). The primary configuration parameters are at the top:

```{Dockerfile}
ARG SRCVERSION=17
ARG SRCTAG=2022-01-17
ARG SRCHUBID=dataeditors
ARG RVERSION=4.1.0
ARG RTYPE=verse
```

where 

- `SRCVERSION` is the Stata version you want to use 
- `SRCTAG` is the tag of the Stata version you want to use as an input
- `SRCHUBID` is where the Stata image comes from - should probably not be modified, but you could use your own.
- `RVERSION` and `RTYPE` are used to pin the `rocker/RTYPE:RVERSION` versioned image. Adjust as necessary

- Finally, edit the [`setup.do`](setup.do) file, which will install any Stata packages into the image.

## Building

Use `build.sh (NAME OF STATA LICENSE FILE)`, e.g.

```{bash}
./build.sh /usr/local/stata/stata.lic
```

## Running

You also need the Stata license for running it all. For convenience, use the `run.sh` script:

```{bash}
./run.sh /usr/local/stata/stata.lic
```

