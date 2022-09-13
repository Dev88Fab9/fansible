#!/bin/bash

f_usage () {

cat << EOS
    Install or remove the Python virtual environment module for any user
    USAGE:
      ${0} -v {0,2,3} -p install   [ -d ]
      ${0} -v {0,2,3} -p uninstall [ -d ]
      ${0} -h
      
      Where:
        -d              => enable debugging
        -h              => display this help
        -v  {1,2,3}     => Which version? pip, pip2 or pip3
        -o              => Operation: install (deploy) or uninstall (remove) ? 
        
        Note that in recent distros pip for python2 should give a DEPRECATION WARNING
        and it is possible it will be no longer available in the near future.
        
      Example:
         ${0} -v 3 -o install
         ${0} -v 3 -o uninstall
EOS
    exit
}
echo 
if [[ $# -lt 4 || $# -gt 5 ]];then  
    f_usage
fi  

while getopts dhv:o: OPT
do
  case "${OPT}" in
        d)
          is_debug=0
          set -x;
          PS4='+${LINENO}:'
          ;;
        h)
          f_usage
          ;;
        o)  
            case "${OPTARG}" in 
                "deploy") op="deploy";;
                "install") op="install";;
                "remove") op="remove";;
                "uninstall") op="uninstall";;
                *) f_usage ;;
            esac
            ;;  
        v)  
          case "${OPTARG}" in
               1) is_pip2="yes";;
               2) is_pip2="no";;
               3) is_pip2="no";;
               *) f_usage;;
          esac   
          ;;
        *)
          f_usage
          ;;            
  esac
done
shift $((OPTIND-1))


f_exit_h () {
    [[ $? -eq 0 ]] && echo "Success."
    if [[ $is_debug -ne 0 ]]; then
        [[ -n "${mytempdir}" ]] && rm -rf "${mytempdir}"
    fi  
}


f_err_h(){
  printf "Script failed with exit code %d in function '%s' at line %d.\n" "$?" "${FUNCNAME[1]}" "${BASH_LINENO[0]}"
  if [[ $is_debug -ne 0 ]]; then
     echo "Please enable debugging mode for more info"
     [[ -n "${mytempdir}" ]] && rm -rf "${mytempdir}"
  fi  
}


trap 'f_err_h;exit 1' ERR
trap '' SIGINT
trap 'f_exit_h $ret' 0 15

echo "Installing Python virtual env package.."


source ./get_python_ints.sh || exit 11
mytempdir=$(mktemp -d) || exit 1
get_python_ints
[[ $? -ne 0 ]] && exit 11
set -eEo pipefail
[[ $(uname) != "Linux" ]] && exit 12


if [[ $(id -u) -eq 0 ]];then
    echo "Warning. You will be running pip as root, this is in general not recommended."
fi  

pip_ints=("pip" "pip2" "pip3")
i=0
for pip_int in "${pip_ints[@]}";do
    if ! command -v "$pip_int"  &>/dev/null;then
         pip_ints[$i]="N/A"
    fi
    i=$(( i + 1 ))
done

while : 
    do
        if  [[ $is_pip2 == "yes" ]];then    
            if [[ ${pip_ints[0]} != "N/A" || ${pip_ints[1]} != "N/A" ]];then
                py_maj_ver=$(python -V 2>&1|awk '{print $NF}'|awk -F '.' '{print $1}')
                if [[ $py_maj_ver -eq 2 ]];then
                    pip_cmd="pip"
                    break
                else 
                    py_maj_ver=$(python2 -V 2>&1|awk '{print $NF}'|awk -F '.' '{print $1}')
                    [[ $py_maj_ver -ne 2 ]] && exit 11
                    pip_cmd="pip2"
                    break
                fi  
            fi  
        else
            if [[ ${pip_ints[2]} != "N/A" ]];then
                py_maj_ver=$(python3 -V 2>&1|awk '{print $NF}'|awk -F '.' '{print $1}')
                [[ $py_maj_ver -ne 3 ]] && exit 11
                pip_cmd="pip3"
                break
            else
                exit 11
            fi
        fi
    done    
        
case $op in 
    "install"|"deploy")
        $pip_cmd install virtualenv >/dev/null || exit 1  
        ;;
    "uninstall"|"remove")   
        echo "y"|$pip_cmd uninstall virtualenv >/dev/null || exit 1
        ;;
    *)
        #we should never enter here
        f_usage
        ;;
esac        
exit 0
