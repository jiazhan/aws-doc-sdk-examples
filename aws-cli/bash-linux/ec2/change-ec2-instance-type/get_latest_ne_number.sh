#!/usr/bin/env bash
###############################################################################
#
# function get_latest_engine_number
#
# This function check NE numbers inside AWS of the specified env and region.
#
# Parameters:
#   -e   [string, mandatory] Specify 'environment' tag value(stg1/prd1/prdeu1)
#   -r   [switch, optional]  Specify region you like to check,default is us-west-2,(us-east-2, eu-central-1)"
#   -v   [switch, optional]  Enable verbose logging.
#   -h   [switch, optional]  Displays this help.
#
# Example:
#       source get_latest_ne_number.sh
#       get_latest_engine_number  -v -e stg1 -r us-west-2    
#
# Returns:
#       NE number if verbose is false
#      all NE instance list if verbose is true
###############################################################################



function get_latest_engine_number {

    function usage() (
        echo ""
        echo "This function check NE numbers inside AWS of the specified env and region."
        echo "Parameter:"
        echo "  -e  Specify 'environment' tag value(stg1/prd1/prdeu1)"
        echo "  -r  Specify region you like to check(us-west-2,us-east-2, eu-central-1)"
        echo "  -v  Enable verbose logging."
        echo ""
    )

    local REGION NE_ENV VERBOSE OPTION RESPONSE 
    local OPTIND OPTARG # Required to use getopts command in a function.

    # Set default values.
    REGION="us-west-2"
    #NE_ENV="stg1"
    VERBOSE=false

    # Retrieve the calling parameters.
    while getopts "e:r:vh" OPTION; do
        case "${OPTION}"
        in
            e)  NE_ENV="${OPTARG}";;
            r)  REGION="${OPTARG}";;
            v)  VERBOSE=true;;
            h)  usage; return 0;;
            \?) echo "Invalid parameter"; usage; return 1;;
        esac
    done

    if [[ -z "$NE_ENV" ]]; then
        echo -e  "ERROR: You must provide an environment value with the -e parameter."
        usage
        return 1
    fi

    if [[ -z "$REGION" ]]; then
        echo -e  "ERROR: You must provide an AWS region value type with the -r parameter."
        usage
        return 1
    fi

    echo -e "Parameters:\n"
    echo  "    Environment:   $NE_ENV"
    echo "    AWS REGION: $REGION"
    echo "    Verbose:       $VERBOSE"
    echo ""

    # 
    echo -e "Confirming existing NE numbers in region $REGION for env $NE_ENV ...\n"
    if [[ $VERBOSE == true ]]; then

    RESPONSE=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=*ne* Name=tag:environment,Values=${NE_ENV} \
  --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name']|[0].Value,State.Name]" \
   --output text --region ${REGION}
              )
    else
    RESPONSE=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=*ne* Name=tag:environment,Values=${NE_ENV} \
  --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name']|[0].Value,State.Name]" \
   --output text --region ${REGION}|awk '{print $2,$3}'|awk -F'.' '{print $2}'|sort -u
              )
    fi
    # check if error 
    #echo " previous : $?"
    if [[  -z "$RESPONSE" ]]; then
        echo -e  "ERROR - fail to check NE number for env $NE_ENV from $REGION .\n$RESPONSE"
        return 1
    fi
    # output result
    echo -e "checking finished...\n"
    if [[ $VERBOSE == true ]]; then
    echo -e "Complete NE instance info: \n----------------------------\n${RESPONSE}"|less
    else
    echo -e "NE number: \n-------------------------\n${RESPONSE}"
    fi

}

#get_latest_engine_number 
