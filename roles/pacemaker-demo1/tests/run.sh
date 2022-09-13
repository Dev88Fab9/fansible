#!/usr/bin/env bash

f_usage(){

  echo -e "Usage:\n ${0} -a CREATE"
  exit
}

while getopts a: OPT
    do
      case "${OPT}" in
           a)
             [[ ${OPTARG} = "CREATE" ]] || f_usage
             ;;
            ?)
               f_usage
               ;;
            *) f_usage
               ;;
      esac
  done

[[ -z "${1}" ]] && f_usage


command -v ansible-playbook &>/dev/null || exit 11

CURRDIR=$(echo "$PWD"|awk -F"/" '{print $NF}')
if [[ $CURRDIR -ne "tests" ]]; then
    echo "This script must run from the 'tests' subdirectory"
    exit 5
fi


mkdir -p "${HOME}/.ansible/roles/"
if ! [[ -h "${HOME}/.ansible/roles/pacemaker-demo-1" ]];then
    ln -s "${PWD}/../" "${HOME}/.ansible/roles/pacemaker-demo-1"
fi

ANS_PLAYBOOK=$(which ansible-playbook)
$ANS_PLAYBOOK -i inventory run-pacemaker-demo-1.yml
