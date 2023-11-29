set -e
jf --version
dockerFileLocation=${IN_dockerFileLocation}
dockerFileName=${IN_dockerFileName}
dockerImage=${IN_dockerImage}
dockerImageName=$(echo $dockerImage | cut -d ':' -f 1)
dockerImageTag=$(echo $dockerImage | cut -d ':' -f 2)
IFS=', ' read -r -a tags <<< "${IN_additionalTags}"
  # Input validations and preparing optional values
additionalTag=""
    for index in "${!tags[@]}"
    do
      echo $index
      additionalTag+="-t $dockerImageName:${tags[index]} "
    done
    if [[ -z "${IN_dockerFileName}" ]]; then
      IN_dockerFileName="Dockerfile"
    fi
    if [[ -z "${IN_optionalParams}" ]]; then
      IN_optionalParams=""
    fi
resourceName=${IN_resourceName}
buildDir="res_${IN_resourceName}_resourcePath"
echo ${!buildDir}

pushd ${!buildDir}

additionalOptions=""
    if [ ! -z "${IN_optionalParams}" ]; then
      additionalOptions="${IN_optionalParams}"
    fi

inputFileResourceNames=$(get_resource_names --type FileSpec --operation IN)

    if [ ! -z "$inputFileResourceNames" ]; then
      echo "$inputFileResourceNames" | jq -r '.[]' | while read inputFileResourceName
    do
      filePath=$(find_resource_variable "$inputFileResourceName" resourcePath)/*
      cp -r $filePath .
      done
    fi
echo $dockerImage
echo $additionalOptions

    if [ ! -z "${IN_dockerFileLocation}" ]; then
      buildDir="${!buildDir}/${IN_dockerFileLocation}"
    else
      buildDir="${!buildDir}"
    fi
echo $buildDir
echo $IN_dockerFileName

docker build $additionalOptions -t $dockerImage $additionalTag -f ${buildDir}/${IN_dockerFileName} .
docker image ls

add_run_variables buildStepName=${step_name}
add_run_variables ${step_name}_payloadType=docker
add_run_variables ${step_name}_buildNumber=$JFROG_CLI_BUILD_NUMBER
add_run_variables ${step_name}_buildName=$JFROG_CLI_BUILD_NAME
add_run_variables ${step_name}_isPromoted=false
add_run_variables ${step_name}_DockerImageName=${dockerImageName}
add_run_variables ${step_name}_DockerImageTag=${dockerImageTag}
popd
jfrog rt build-collect-env $JFROG_CLI_BUILD_NAME $JFROG_CLI_BUILD_NUMBER
add_run_files /tmp/jfrog/. jfrog