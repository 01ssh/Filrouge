#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
ENV_WORSKPACE=development
WORKING_DIR=tf/infra
ACCOUNT=DST
REGION="eu-west-3"

declare -A _SETTINGS

function init()
{
   export TF_VAR_ACCOUNT=$1
   export TF_ENV_WORKSPACE=$2
   export _WORKING_DIR=${SCRIPTPATH}/$3
   
   
   setenv ${TF_VAR_ACCOUNT} ${TF_ENV_WORKSPACE}
   echo "CURRENT_WORKING_DIRECTORY:${_WORKING_DIR}"
   terraform -chdir=${_WORKING_DIR} init -upgrade -var ENV_WORKSPACE=$TF_ENV_WORKSPACE -var ACCOUNT=$TF_VAR_ACCOUNT
   unsetenv ${TF_VAR_ACCOUNT} ${TF_ENV_WORKSPACE}
}

function start()
{
   export _WORKING_DIR=${SCRIPTPATH}/$1
   [[ ! -z $2 ]] && export TF_VAR_ACCOUNT=$2
   [[ ! -z $3 ]] && export TF_VAR_CICD_VAULT_TOKEN=$3
   [[ ! -z $4 ]] && export TF_ENV_WORKSPACE=$4

   echo "setenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}"
   setenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}
   terraform -chdir=${_WORKING_DIR} init
   terraform -chdir=${_WORKING_DIR} plan  -var ENV_WORKSPACE=$TF_ENV_WORKSPACE -var ACCOUNT=$TF_VAR_ACCOUNT
   terraform -chdir=${_WORKING_DIR} apply -auto-approve -var ENV_WORKSPACE=$TF_ENV_WORKSPACE -var ACCOUNT=$TF_VAR_ACCOUNT
   unsetenv ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}
   echo "unsetenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}"
   exit 0
}

function destroy()
{
  export _WORKING_DIR=${SCRIPTPATH}/$1
  [[ ! -z $2 ]] && export TF_VAR_ACCOUNT=$2
  [[ ! -z $3 ]] && export TF_VAR_CICD_VAULT_TOKEN=$3
  [[ ! -z $4 ]] && export TF_ENV_WORKSPACE=$4
  
  echo "setenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}"
  setenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}
  terraform -chdir=${WORKING_DIR} destroy -auto-approve -var ENV_WORKSPACE=$TF_ENV_WORKSPACE -var ACCOUNT=$TF_VAR_ACCOUNT
  unsetenv ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}
  echo "unsetenv   ${TF_VAR_ACCOUNT}  ${TF_ENV_WORKSPACE}"
}

function unsetenv()
{
   ENV_ACCOUNT=$1
   ENV_WORKSPACE=$2

    sed -i s/${ENV_WORKSPACE}/%WORKSPACE%/g ${SCRIPTPATH}/${WORKING_DIR}/setting.values
    sed -i s/${ENV_ACCOUNT}/%env%/g ${SCRIPTPATH}/${WORKING_DIR}/setting.values
    sed -i "s/= *\(.*\)#replace.\(.*\)/=%\2%#replace.\2/g" ${SCRIPTPATH}/${WORKING_DIR}/provider.tf
}

function setenv()
{
    ENV_ACCOUNT=$1
    ENV_WORKSPACE=$2
    
    sed -i s/%ACCOUNT%/${ENV_ACCOUNT}/g ${SCRIPTPATH}/${WORKING_DIR}/setting.values
    sed -i s/%WORKSPACE%/${ENV_WORKSPACE}/g ${SCRIPTPATH}/${WORKING_DIR}/setting.values

    if [ -f ${SCRIPTPATH}/${WORKING_DIR}/setting.values ]; then
      while read line
        do
           _KEY=$(echo -n $line   | awk -F'=' '{print $1}')
           _VALUE=$(echo -n $line | awk -F'=' '{print $2}')
           _SETTINGS[${_KEY}]="${_VALUE}"
        done < ${SCRIPTPATH}/${WORKING_DIR}/setting.values
    fi
    for key in "${!_SETTINGS[@]}"
    do
          echo "${key}:${_SETTINGS[${key}]}"
          v=${_SETTINGS[${key}]}
          sed -i s/%$key%/$v/g ${SCRIPTPATH}/${WORKING_DIR}/provider.tf 
    done
}


  while getopts "P:p:isdEu:t:Uw:" opt;
    do
       case $opt in
       E)
          setenv "${ACCOUNT}" "${ENV_WORKSPACE}"
          ;;
       U)
          unsetenv "${ACCOUNT}" "${ENV_WORKSPACE}"
          ;;
       i)
          init  "${ACCOUNT}" "${ENV_WORKSPACE}" "${WORKING_DIR}"
          ;;
       u)
          ACCOUNT=$OPTARG
          ;; 
       w)
          echo "ENV_WORKSPACE=$OPTARG"
          ENV_WORKSPACE=$OPTARG
          ;; 
       p)
          WORKING_DIR=$OPTARG
          ;;
       t)
          export CICD_VAULT_TOKEN=$OPTARG
          ;;
       s)
          start   "${WORKING_DIR}" "${ACCOUNT}" "${CICD_VAULT_TOKEN}" "${ENV_WORKSPACE}"
	      ;;
       d)
          destroy "${WORKING_DIR}" "${ACCOUNT}" "${CICD_VAULT_TOKEN}" "${ENV_WORKSPACE}"
          ;; 
	   \?)
	      exit 1
          ;;
       esac
   done
