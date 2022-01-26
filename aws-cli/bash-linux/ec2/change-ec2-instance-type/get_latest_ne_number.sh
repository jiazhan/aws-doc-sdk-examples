#!/usr/bin/env bash
###############################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# This file is licensed under the Apache License, Version 2.0 (the "License").
#
# You may not use this file except in compliance with the License. A copy of
# the License is located at http://aws.amazon.com/apache2.0/.
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
###############################################################################
#// snippet-start:[ec2.bash.change-instance-type.complete]
###############################################################################
#
# function change_ec2_instance_type
#
# This function changes the instance type of the specified Amazon EC2 instance.
#
# Parameters:
#   -i   [string, mandatory] The instance ID of the instance whose type you
#                            want to change.
#   -t   [string, mandatory] The instance type to switch the instance to.
#   -f   [switch, optional]  If set, the function doesn't pause and ask before
#                            stopping the instance.
#   -r   [switch, optional]  If set, the function restarts the instance after
#                            changing the type.
#   -v   [switch, optional]  Enable verbose logging.
#   -h   [switch, optional]  Displays this help.
#
# Example:
#      The following example converts the specified instance to type "t2.micro"
#      without pausing to ask permission. It automatically restarts the
#      instance after changing the type.
#
#      change_ec2_instance_type -i i-123456789012 -t t2.micro -f -r
#
# Returns:
#      0 if successful
#      1 if it fails
###############################################################################

# Import the general_purpose functions.
source awsdocs_general.sh

######################################
#
#  See header at top of this file
#
######################################

function get_latest_engine_number {

    function usage() (
        echo ""
        echo "This function changes the instance type of the specified instance."
        echo "Parameter:"
        echo "  -e  Specify 'environment' tag value(stg1/prd1/prdeu1)"
        echo "  -r  Specify region you like to check(us-west-2,us-east-2, eu-central-1)"
        echo "  -v  Enable verbose logging."
        echo ""
    )

    local FORCE RESTART REGION NE_ENV VERBOSE OPTION RESPONSE ANSWER
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
        errecho "ERROR: You must provide an environment value with the -i parameter."
        usage
        return 1
    fi

    if [[ -z "$REGION" ]]; then
        errecho "ERROR: You must provide an AWS region value type with the -r parameter."
        usage
        return 1
    fi

    echo "Parameters:\n"
    echo "    Environment:   $NE_ENV"
    echo "    AWS REGION: $REGION"
    echo "    Verbose:       $VERBOSE"
    echo ""

    # 
    echo -n "Confirming existing NE numbers in region $REGION for env $NE_ENV ..."
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
    if [[ ${?} -ne 0 ]]; then
        errecho "ERROR - fail to check NE number for env $NE_ENV from $REGION .\n$RESPONSE"
        return 1
    fi
    echo -e "checking finished...\n"
    if [[ $VERBOSE == true ]]; then
    echo -e "Complete NE instance info: \n----------------------------\n${RESPONSE}"|less
    else
    echo -e "NE number: \n-------------------------\n${RESPONSE}"
    fi

}

#get_latest_engine_number 
#// snippet-end:[ec2.bash.change-instance-type.complete]
