#!/bin/bash
set -u

REGION="ap-northeast-1"
LOG_GROUPS=(
"/aaa"
"/bbb"
"/ccc"
)
S3_BUCKET="testbucket"
DAYS_AGO="3"
DRYRUN_FLAG="true"

region=${REGION}
log_groups=("${LOG_GROUPS[@]}")
s3_bucket=${S3_BUCKET}
days_ago=${DAYS_AGO}
dryrun_flag=${DRYRUN_FLAG}

retry_limit=50
interval=5
archive_date=$(date -d "${days_ago} days ago" +%Y/%m/%d)
yyyymmdd_archive_date=$(date -d "${archive_date}" +%Y-%m-%d)
unix_from_archive_date=$(date -d "${archive_date} 00:00:00" +%s000)
unix_to_archive_date=$(date -d "${archive_date} 23:59:59" +%s999)

function check_task() {
    check_task_region=${1}
    check_task_task_name=${2}
    check_task_result=`aws logs describe-export-tasks --region ${check_task_region} --status-code "COMPLETED" --output text --limit 3`
    if [[ "${check_task_result}" =~ ${check_task_task_name} ]]; then
        return 0
    else
        return 1
    fi
}

for log_group_name in "${log_groups[@]}"
do
    s3_bucket_prefix="cloudwatchlogs${log_group_name}/${yyyymmdd_archive_date}"
    yyyymmddhms_date=`date +%Y-%m-%d-%H%M%S`
    name_snakecase=`echo ${log_group_name} | sed "s/\//_/g"`
    task_name="${yyyymmddhms_date}${name_snakecase}"

    if ${dryrun_flag} ; then
        echo "dryrun is true"
        echo "region: ${region}"
        echo "task_name: ${task_name}"
        echo "log-group-name: ${log_group_name}"
        echo "from data(UNIX): ${unix_from_archive_date}"
        echo "to data(UNIX): ${unix_to_archive_date}"
        echo "destination S3 bucket: ${s3_bucket}"
        echo "destination-prefix: ${s3_bucket_prefix}"
    else
        echo "dryrun is false"
        aws logs create-export-task \
            --region             ${region} \
            --task-name          ${task_name} \
            --log-group-name     ${log_group_name} \
            --from               ${unix_from_archive_date} \
            --to                 ${unix_to_archive_date} \
            --destination        ${s3_bucket} \
            --destination-prefix ${s3_bucket_prefix}
    fi

    sleep ${interval}

    retry_number=0
    while [ ${retry_number} -ne ${retry_limit} ]
    do
        if ${dryrun_flag} ; then
            echo "dryrun is true"
            echo "skip check task function"
            break
        fi

        check_task ${region} ${task_name}
        if [ ${?} -eq 0 ] ; then
            break
        else
            retry_number=`expr 1 + ${retry_number}`
        fi
    done

    if [ ${retry_number} -eq ${retry_limit} ] ; then
        echo "error: retry_number is limit"
        exit 1
    fi
done

