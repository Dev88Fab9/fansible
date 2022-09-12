#!/bin/bash

f_usage () {

cat << EOS
    Script to install Ansible through pip
    
    USAGE:
      ${0} -i {1,2,3} -n env_name [-v] ansible_version [ -d ] 
      
      Where
        -d                 => enable debugging
        -h                 => Display this help
        -i {1,2,3}         => install through pip, pip2 or pip3
        -n venv_name       => create a virtual env first
        -v                 => optional: ansible version 
    
      Note that:
      a)usage of pip or pip2 is kind deprecated and might not work in 
      the future if it is related to python2 
      b)The script provision ansible only through a virtual environment
      
      
      Examples:
         ${0} -i 3 -n ansible_test2 -d
         ${0} -i 3 -n ansible_test3 -v 4.1.0 -d
EOS
    exit
}

if [[ $# -lt 4 || $# -gt 7 ]];then  
    f_usage
fi  

while getopts dhi:n:v: OPT
do
  case "${OPT}" in
        d)
          set -x;
          PS4='+${LINENO}:'
          ;;
        i)
          case "${OPTARG}" in 
              "1") main_cmd="pip";;
              "2") main_cmd="pip2";;
              "3") main_cmd="pip3";;
              *)   f_usage;;
          esac
          ;;   
        n)  
          [[ -z "${OPTARG}" ]] && f_usage
          venv_name="${OPTARG}"
          ;;
        h)
          f_usage
          ;;
         v)
           ans_vers="${OPTARG}"
           ;;
        *)
          f_usage
          ;;            
  esac
done
shift $((OPTIND-1))

set -eEo pipefail

f_exit_h () {
    [[ $? -eq 0 ]] && echo "Success."
}

f_err_h(){
  printf "Script failed with exit code %d in function '%s' at line %d.\n" "$?" "${FUNCNAME[1]}" "${BASH_LINENO[0]}"
  if [[ $is_debug -ne 0 ]]; then
     echo "Please enable debugging mode for more info"
  fi  
}

trap 'f_err_h;exit 1' ERR
trap '' SIGINT
trap 'f_exit_h $ret' 0 15

echo "Provisioning Ansible..."

echo -n "a: creating virtual env first. "
cd &>/dev/null && virtualenv "${venv_name}" &>/dev/null || exit 1
cd "./${venv_name}" &>/dev/null || exit 1
source "./bin/activate"   &>/dev/null || exit 1
echo " OK."

echo -n "b: Installing Ansible."
if [[ -n "${ans_vers}" ]];then
    $main_cmd install ansible=="${ans_vers}" || exit 1
else
    $main_cmd install ansible || exit 1
fi  
echo " OK."


source "./bin/activate dectivate" &>/dev/null || true
exit 0