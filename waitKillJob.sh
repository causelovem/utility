#!/bin/bash --

# функция, следящая за количеством запущенных jobs
# $1 - имя job (string)
# $2 - максимальное количество запущенных $1 (int)
# $3 - сколько спать (sec)
function waitJob
{
    # количество работающих процессов сейчас
    jobsCount=$(( $(jobs | grep "Запущен.*$1" | wc -l) + 0))
    # jobsCount=$(( $(jobs | grep "Running.*$1" | wc -l) + 0))

    # пока их больше чем нужно - спим
    while [ $jobsCount -gt $2 ]
    do
        sleep $3
        jobsCount=$(($(jobs | grep "Запущен.*$1" | wc -l) + 0))
        # jobsCount=$(( $(jobs | grep "Running.*$1" | wc -l) + 0))
    done

    echo "$(date +%Y-%m-%d\ %H:%M:%S): Awake, ${jobsCount} jobs working."
}


# функция убивает оставшиеся jobs от текущего процесса
function killJob
{
    echo "$(date +%Y-%m-%d\ %H:%M:%S): Запущен jobs: $(( $(jobs | grep "Запущен" | wc -l) + 0))."
    # echo "$(date +%Y-%m-%d\ %H:%M:%S): Running jobs: $(( $(jobs | grep "Running" | wc -l) + 0))."

    # список процессов, которые нужно убить
    jobsToKill="$(jobs -l | gawk '{ if($2=="Запущен"){jobsToKill=jobsToKill " " $1} else if($3=="Запущен"){jobsToKill=jobsToKill " " $2} } END {print jobsToKill}')"
    # jobsToKill="$(jobs -l | gawk '{ if($2=="Running"){jobsToKill=jobsToKill " " $1} else if($3=="Running"){jobsToKill=jobsToKill " " $2} } END {print jobsToKill}')"
    try=0

    # пока список не пустой
    while [[ "${jobsToKill}" != "" ]]
    do
        # echo "ERROR: Some jobs is still Запущен (${jobsToKill})."
        echo "ERROR: Some jobs is still Running (${jobsToKill})."
        # jobs | grep Запущен
        # jobs | grep Running

        try=$((${try} + 1))

        # пытаемся убить процессы
        echo -e "\nkill ${jobsToKill}"
        kill ${jobsToKill}

        sleep 5

        # даём 10 попыток на убийство всех процессов
        if [ ${try} -ge 10 ]
        then
            echo "Can not kill all jobs. Exiting."
            break
        fi

        # список процессов, которые нужно убить
        jobsToKill="$(jobs -l | gawk '{ if($2=="Запущен"){jobsToKill=jobsToKill " " $1} else if($3=="Запущен"){jobsToKill=jobsToKill " " $2} } END {print jobsToKill}')"
        # jobsToKill="$(jobs -l | gawk '{ if($2=="Running"){jobsToKill=jobsToKill " " $1} else if($3=="Running"){jobsToKill=jobsToKill " " $2} } END {print jobsToKill}')"

    done

    echo "$(date +%Y-%m-%d\ %H:%M:%S): Запущен jobs: $(( $(jobs | grep "Запущен" | wc -l) + 0))."
    # echo "$(date +%Y-%m-%d\ %H:%M:%S): Running jobs: $(( $(jobs | grep "Running" | wc -l) + 0))."
}
