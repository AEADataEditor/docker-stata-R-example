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
STATALIC=/path/to/stata.lic
```

where

- `VERSION` is the Stata version you want to use (this might be ignored right now)
- `TAG` is the Docker tag you will be using - could be "latest", could be a specific name. Has to be lower-case.
- `MYHUBID` is presumably your Docker login
- `MYIMG` is the name you want to give the Docker image you are creating. By default, it presumes that it will be the same name as the Git repository.
- `STATALIC`  is the path to a valid Stata license file (for instance, as installed on your laptop)

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
./build.sh 
```

### Notes about Stata licenses

Because Stata is licensed software, you need to have a valid license to **run** the software. If you include this in the Docker container itself, then you should **not publish** the container, since it will permanently include the license (even if you first include it, and then remove it, unless you become really tricky...). 

So how should you go about building into the container some of the packages? You should not. You should instead include these as part of a replication package. However, you can use the container to set them up as follows:

- [Build the container](./build.sh) - no license file required.
- Run the container a first time, with the setup script that installs the packages. You should include a configuration that uses a [project-specific ado directory](https://larsvilhuber.github.io/self-checking-reproducibility/12-environments-in-stata.html). You will later use the same config to run the code itself, so your setup program might look like this:

```{stata}
// setup.do

include "config.do"
// install packages
ssc install estout
```

- Your `config.do` would look like [this one](https://larsvilhuber.github.io/self-checking-reproducibility/12-environments-in-stata.html#using-environments-in-stata). 
- Your `main.do` would not re-execute the `setup.do`, but **would** include the `config.do` that redirects Stata to use the project-specific ado directory:

```{stata}
// main.do
include "config.do"
// rest of the code
```

- Your replication package would include the `setup.do`, the `config.do`, the `main.do`, and the `ado` directory created. 


## Running

You also need the Stata license for running it all. For convenience, use the `run.sh` script:

```{bash}
./run.sh 
```

