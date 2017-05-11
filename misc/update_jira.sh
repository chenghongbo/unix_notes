#!/bin/bash

keyID=$1 		## such as EPMESPDEPI-404
Requested_status=$2  	## Resolved, or "In Progress"
Requested_version=$3 	## v2.5.2

JIRA_BASE_URL='http://epcnszxw0150.princeton.example.com:8888'
JIRA_TRANSITION_URL=${JIRA_BASE_URL}/rest/api/latest/issue/${keyID}/transitions
JIRA_META_URL=${JIRA_BASE_URL}/rest/api/latest/issue/${keyID}/editmeta

JIRA_PASSWORD='admin:admin'  ## this could be secured using Jenkins credential bindings

## declare an associative array. will not work if bash version < 4
## get transition name (a.k.a status) and its corresponding ID with the following command:

## ---- replace JIRA site URL and key ID (AT-2) with your own

## curl -s -uadmin:admin http://epcnszxw0150.princeton.example.com:8888/rest/api/2/issue/AT-2/transitions |jq '.transitions[]'|jq '.name,.id'
## output:
#	"To Do"
#	"11"
#	"In Progress"
#	"21"
#	"Done"
#	"31"

declare -A transitionNameID=([To Do]=11 [In Progress]=21 [Done]=31)

## get fixed versions with following command:
## curl -s -u$JIRA_PASSWORD ${JIRA_META_URL} |jq '.fields.fixVersions.allowedValues[].name'|sed 's#"##g'

## replace version with your own
## declare -a fixversion=(v0.0.3 v0.0.6 v0.0.9)


## updating ticket
JIRA_UPDATE_URL=${JIRA_BASE_URL}/rest/api/latest/issue/${keyID}
 
echo "updating fix Version/s ......"
curl -s -D- -u$JIRA_PASSWORD -X PUT --data '{
"update": {"fixVersions": [ {"set": [{"name": "'"$Requested_version"'"}]}]}
}' -H 'Content-Type: application/json'  $JIRA_UPDATE_URL > /dev/null

## get transition ID based on status name (such as 'Resolved')
JIRA_TRANSITION_UPDATE_URL="${JIRA_BASE_URL}/rest/api/latest/issue/${keyID}/transitions?expand=transitions.fields"
JIRA_COMMENT_UPDATE_URL="${JIRA_BASE_URL}/rest/api/latest/issue/${keyID}/comment"
comment="updating to status $Requested_status or fix version to $Requested_version"
status_id=${transitionNameID[$Requested_status]}
if [[ -n "$status_id" ]];then
	## update transition, or Status
	echo "updating status ......"
	curl -s -D- -u$JIRA_PASSWORD -X POST --data '{"transition": {"id": "'$status_id'"}}' -H "Content-Type: application/json" $JIRA_TRANSITION_UPDATE_URL > /dev/null
	echo "adding comment ......"
	curl -s -D- -u$JIRA_PASSWORD -X POST --data '{ "body": "'"$comment"'"}' -H"Content-Type: application/json" $JIRA_COMMENT_UPDATE_URL > /dev/null

else
	echo "failed to get transition ID for $2 status"
fi
