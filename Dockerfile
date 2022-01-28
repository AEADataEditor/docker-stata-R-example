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

# copy the license in so we can do the install of packages
USER root
RUN --mount=type=secret,id=statalic \
    cp /run/secrets/statalic /usr/local/stata/stata.lic \
    && chmod a+r /usr/local/stata/stata.lic

# Stuff we need from the Stata Docker Image
# https://github.com/AEADataEditor/docker-stata/blob/f2c0d52f133a32c6892fe1f67796322390ce7c35/Dockerfile#L15
# We need to redo this here, since we are using the base image from `rocker`. 
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         locales \
         libncurses5 \
         libfontconfig1 \
         git \
         nano \
         unzip \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8


# Set a few more things
ENV LANG en_US.utf8

#=============================================== REGULAR USER
# install any packages into the home directory as the user
# NOTE: in contrast to the base Docker image, we are using
# the "normal" user from the `rocker` image, to keep things
# simple

USER rstudio
COPY setup.do /setup.do
WORKDIR /home/statauser
RUN /usr/local/stata/stata do /setup.do | tee setup.$(date +%F).log

#=============================================== Clean up
#  then delete the license again
USER root
RUN rm /usr/local/stata/stata.lic

# Setup for standard operation
USER rstudio
WORKDIR /code
ENTRYPOINT ["stata-mp"]

