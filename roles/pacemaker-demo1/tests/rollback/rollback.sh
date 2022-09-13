#!/usr/bin/bash

f_usage(){

  echo -e "Usage:\n ${0} -a DESTROY"
  exit
}

while getopts a: OPT
    do
      case "${OPT}" in
           a)
             [[ ${OPTARG} = "DESTROY" ]] || f_usage
             ;;
            ?)
               f_usage
               ;;
            *) f_usage
               ;;
      esac
  done

[[ -z "${1}" ]] && f_usage

CURRDIR=$(echo "$PWD"|awk -F"/" '{print $NF}')
if [[ $CURRDIR -ne "rollback" ]]; then
    echo "This script must run from the 'rollback' subdirectory"
    exit 5
fi

command -v ansible-playbook &>/dev/null || exit 11
ANS_PLAYBOOK=$(which ansible-playbook)
sudo "${ANS_PLAYBOOK}" -i ../inventory rollback-cl.yml
sudo "${ANS_PLAYBOOK}" -i ../inventory rollback.yml

exit $?
