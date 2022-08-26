#!/bin/bash
PWD=$(pwd)
repo=${PWD##*/}
space=larsvilhuber
case $USER in
  vilhuber)
  #WORKSPACE=$HOME/Workspace/git/
  WORKSPACE=$PWD
  ;;
  codespace)
  WORKSPACE=/workspaces
  ;;
esac
  
# build the docker if necessary

docker pull $space/$repo 
BUILD=yes
arg1=$1

if [[ $? == 1 ]]
then
  ## maybe it's local only
  docker image inspect $space/$repo > /dev/null
  [[ $? == 0 ]] && BUILD=no
fi
# override
[[ "$arg1" == "force" ]] && BUILD=yes

BUILD=no
if [[ "$BUILD" == "yes" ]]; then
docker build . -t $space/$repo
nohup docker push $space/$repo &
fi

docker run -e DISABLE_AUTH=true -v $WORKSPACE:/home/rstudio --rm -p 8787:8787 $space/$repo
