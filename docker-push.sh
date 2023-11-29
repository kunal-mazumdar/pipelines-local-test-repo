set -e
jf --version
restore_run_files /tmp/jfrog/. jfrog
dockerImage=${IN_dockerImage}
dockerImageName=$(echo $dockerImage | cut -d ':' -f 1)
dockerImageTag=$(echo $dockerImage | cut -d ':' -f 2)
hostname=$(echo $step_url | cut -d / -f3)
  # Input validations and updating optional values
hostname=$(echo $step_url | cut -d / -f3)
  # Input validations and updating optional values
    if [[ -z "${IN_autoPublishBuildInfo}" ]]; then
      IN_autoPublishBuildInfo="false"
    fi
    if [[ -z "$IN_xrayScan" ]]; then
      IN_xrayScan="false"
    fi
    if [[ -z "${IN_failOnScan}" ]]; then
      IN_failOnScan="true"
    else
       IN_failOnScan="false"
    fi
docker image ls
  # START Add run variables
  # START Add run variables
add_run_variables buildStepName=${step_name}
add_run_variables ${step_name}_payloadType=docker
add_run_variables ${step_name}_buildNumber=$JFROG_CLI_BUILD_NUMBER
add_run_variables ${step_name}_buildName=$JFROG_CLI_BUILD_NAME
add_run_variables ${step_name}_isPromoted=false
add_run_variables ${step_name}_DockerImageName=${dockerImageName}
add_run_variables ${step_name}_DockerImageTag=${dockerImageTag}
  # END Add run variables
  # START collect build environment variables
  # END Add run variables
  # START collect build environment variables
jfrog rt build-collect-env $JFROG_CLI_BUILD_NAME $JFROG_CLI_BUILD_NUMBER
  # END collect build environment variables
  # END collect build environment variables
buildNumber=$(eval echo "$""$buildStepName"_buildNumber)
buildName=$(eval echo "$""$buildStepName"_buildName)
buildPublishOutputFile="$step_tmp_dir/buildPublishOutput.json"
dockerPushOutputFile="$step_tmp_dir/dockerPushOutput.json"
  # Perform Docker Push
jf docker push $dockerImageName:$dockerImageTag --build-name=$buildName --build-number=$buildNumber --detailed-summary | tee $dockerPushOutputFile
  # saving docker push artifact info
echo "--- DOCKER OVER ---"
echo $dockerPushOutputFile
save_artifact_info file $dockerPushOutputFile
echo "--- SAVE FILE OVER ---"
# pipelineSourceBranch=`echo $pipeline_source_branch`
#   # START Fetch pipeline branch name to store
#     if [[ -z "$pipelineSourceBranch" ]]; then
#       read pipelineId pipelineSourceId < <(curl https://$hostname/pipelines/api/v1/steps/$step_id --header "Authorization: Bearer $builder_api_token" | jq -r '.pipelineId, .pipelineSourceId')
#       read isMultiBranch branch < <(curl https://$hostname/pipelines/api/v1/pipelineSources/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq -r '.isMultiBranch, .branch')
#       if [ "$isMultiBranch" == "true" ]; then
#         pipelineSourceBranch=`curl https://$hostname/pipelines/api/v1/pipelines/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq .pipelineSourceBranch | tr -d \"`
#       else
#         pipelineSourceBranch=branch | tr -d \"
#       fi
#       pipelineSourceBranch=`curl https://$hostname/pipelines/api/v1/pipelines/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq .pipelineSourceBranch`
#       echo $pipelineSourceBranch
#     fi
#   # END Fetch pipeline branch name to store
#   # START build-publish and save artifact info
# outputBuildName=`echo $buildName\_$pipelineSourceBranch | tr -d \"`
# echo $outputBuildName
# pipelineSourceBranch=`echo $pipeline_source_branch`
#   # START Fetch pipeline branch name to store
#     if [[ -z "$pipelineSourceBranch" ]]; then
#       read pipelineId pipelineSourceId < <(curl https://$hostname/pipelines/api/v1/steps/$step_id --header "Authorization: Bearer $builder_api_token" | jq -r '.pipelineId, .pipelineSourceId')
#       read isMultiBranch branch < <(curl https://$hostname/pipelines/api/v1/pipelineSources/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq -r '.isMultiBranch, .branch')
#       if [ "$isMultiBranch" == "true" ]; then
#         pipelineSourceBranch=`curl https://$hostname/pipelines/api/v1/pipelines/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq .pipelineSourceBranch | tr -d \"`
#       else
#         pipelineSourceBranch=branch | tr -d \"
#       fi
#       pipelineSourceBranch=`curl https://$hostname/pipelines/api/v1/pipelines/$pipelineId --header "Authorization: Bearer $builder_api_token" | jq .pipelineSourceBranch`
#       echo $pipelineSourceBranch
#     fi
#   # END Fetch pipeline branch name to store
#   # START build-publish and save artifact info
# outputBuildName=`echo $buildName\_$pipelineSourceBranch | tr -d \"`
echo $outputBuildName
echo $IN_autoPublishBuildInfo
    if [ "$IN_autoPublishBuildInfo" == "true" ]; then
      echo "--- INSIDE BUILD PUBLISH---"
      if [ -z "$JFROG_CLI_ENV_EXCLUDE" ]; then
        export JFROG_CLI_ENV_EXCLUDE="buildinfo.env.res_*;buildinfo.env.int_*;buildinfo.env.current_*;*password*;*secret*;*key*;*token*"
      fi
      retry_command jfrog rt build-publish --detailed-summary --insecure-tls=$no_verify_ssl $outputBuildName $buildNumber > $buildPublishOutputFile
      save_artifact_info buildInfo $buildPublishOutputFile --build-name $outputBuildName --build-number $buildNumber
      retry_command jfrog rt build-publish --detailed-summary --insecure-tls=$no_verify_ssl $outputBuildName $buildNumber > $buildPublishOutputFile
      save_artifact_info buildInfo $buildPublishOutputFile --build-name $outputBuildName --build-number $buildNumber
      cat $buildPublishOutputFile
    fi
  # END build-publish and save artifact info
  # START Update buildinfo output resource
  # END build-publish and save artifact info
  # START Update buildinfo output resource
    if [ -n "$IN_outputBuildInfoResourceName" ]; then
      write_output $IN_outputBuildInfoResourceName buildName=$outputBuildName buildNumber=$buildNumber
      write_output $IN_outputBuildInfoResourceName buildName=$outputBuildName buildNumber=$buildNumber
    fi
  # END Update buildinfo output resource
  # START perform xray scan
  # END Update buildinfo output resource
  # START perform xray scan
# xrayScanResultsOutputFile="$step_tmp_dir/xrayScanResultsOutput.json"
# echo $IN_xrayScan
# echo $IN_failOnScan
#     if [ "$IN_xrayScan" == "true" ]; then
#       onScanComplete() {
#         cat $xrayScanResultsOutputFile
#         xrayUrl=$(jq -c '.[0].xray_data_url' "$xrayScanResultsOutputFile" --raw-output 2> /dev/null)
#         if [ -n "$xrayUrl" ]; then
#           save_xray_results_url "$xrayUrl"
#         fi
#       }
#       jf build-scan --fail="$IN_failOnScan" --format=json $outputBuildName $buildNumber > $xrayScanResultsOutputFile || (onScanComplete; exit 99)
#       jf build-scan --fail="$IN_failOnScan" --format=json $outputBuildName $buildNumber > $xrayScanResultsOutputFile || (onScanComplete; exit 99)
#     fi
  # END perform xray scan
  # END perform xray scan