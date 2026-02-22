# syntax=docker/dockerfile:1.2
ARG SRCVERSION=17
ARG SRCTAG=2022-01-17
ARG SRCHUBID=dataeditors
ARG RVERSION=4.1.0
ARG RTYPE=verse

# define the source for Stata
FROM ${SRCHUBID}/stata${SRCVERSION}:${SRCTAG} as stata

# use the source for R

FROM rocker/${RTYPE}:${RVERSION}
COPY --from=stata /usr/local/stata/ /usr/local/stata/
RUN echo "export PATH=/usr/local/stata:${PATH}" >> /root/.bashrc
ENV PATH "$PATH:/usr/local/stata" 

USER root

# Stuff we need from the Stata Docker Image
# For images that use Ubuntu 22.04 or earlier: https://github.com/AEADataEditor/docker-stata/blob/f2c0d52f133a32c6892fe1f67796322390ce7c35/Dockerfile#L15
# For later images using Ubuntu 24.04: https://github.com/AEADataEditor/docker-stata/blob/fddd12c7abc557d2d744a02e95ecbed28a1a2b9e/Dockerfile.base#L24
# We need to redo this here, since we are using the base image from `rocker`. 
# 
# IMPORTANT! If you are using earlier images, replace this code with the one referenced above for Ubuntu 22.04 or earlier.
#


RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         libncurses6 \
         libcurl4 \
         git \
         nano \
         unzip \
         locales \
         fontconfig fonts-dejavu-core fonts-dejavu-extra \
         fonts-liberation \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8


# Set a few more things
ENV LANG en_US.utf8

#=============================================== REGULAR USER
# NOTE: in contrast to the base Docker image, we are using
# the "normal" user from the `rocker` image, to keep things
# simple

# Setup for standard operation
USER rstudio
WORKDIR /code
ENTRYPOINT ["stata-mp"]

# Setup for Rstudio operation
# comment out the above section!
#
#USER ROOT
#EXPOSE 8787
#CMD ["/init"]
