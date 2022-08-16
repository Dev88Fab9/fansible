#!/bin/bash

PIPURL="https://bootstrap.pypa.io/get-pip.py"
is_pip2=""

f_usage () {

cat << EOS
	Install pip, pip2 oe pip3
    USAGE:
      ${0} -s {2,3} | -o {0,2,3} [ -d ]
      
      Where
        -g {2,3} [-d ]   => install by the get-pip.py script, for PY2 or PY3
        -o {0,2,3} [-d ] => install distro provided version (pip, pip2 or pip3)
        -d               => enable debugging
    
      Note that -p and -o are mutually exclusive!
      
      Example:
         ${0} -d -g 2
         ${0} -o 3
EOS
    exit
}
echo 
if [[ $# -lt 2 || $# -gt 3 ]];then  
    f_usage
fi  

while getopts dg:ho: OPT
do
  case "${OPT}" in
        d)
          is_debug=0
          set -x;
          PS4='+${LINENO}:'
          ;;
        g)
          [[ $is_install_o == "yes" ]] && f_usage
          is_install_g="yes"  
          case "${OPTARG}" in 
              "2") is_pip2="yes";;
              "3") is_pip2="no";;
              *)   f_usage;;
          esac
          ;;   
        o)  
          [[ $is_install_g == "yes" ]] && f_usage
          is_install_o="yes" 
          case "${OPTARG}" in
             0) pkg="pip";;
             2) pkg="pip2";;
             3) pkg="pip3";;
             *) f_usage;;
          esac
          ;;
        h)
          f_usage
          ;;
        *)
          f_usage
          ;;            
  esac
done
shift $((OPTIND-1))
if [[ -z $is_install_g && -z $is_install_o ]];then
   f_usage
fi

command -v curl &>/dev/null || exit 11
source ./get_python_ints.sh || exit 11
mytempdir=$(mktemp -d) || exit 1
get_python_ints
[[ $? -ne 0 ]] && exit 11
set -eEo pipefail

[[ $(uname) != "Linux" ]] && exit 12
if ! command -v python &>/dev/null;then
   echo "The python symlink is missing."
   exit 11
fi   

if [[ $(id -u) -eq 0 ]];then
    echo "Warning! It is not recommended to install  pip as root."
    echo ""
fi

 
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


f_inst_g () {
   #Install through the get-pip.py script   
   
   curl -sSL "${PIPURL}" -o "${mytempdir}/get-pip.py"   
   if [[ $is_pip2 == "yes" ]];then
       py_maj_ver=$(python -V|awk '{print $NF}'|awk -F '.' '{print $1}')
       if  [[ $py_maj_ver -ne 2 ]];then
          echo "The default python is not python 2."
          exit 1
       fi     
       parms="${mytempdir}/get-pip.py pip <21.0"
   else
       parms="${mytempdir}/get-pip.py"
   fi      
   
   
   #Checking if the script suggests another version
   set +eEo pipefail;trap - ERR;omsg="def"
   omsg=$(set +eEo pipefail;python "$parms" 2>&1)
   ourl=$(echo "$omsg"|awk '{print $(NF-1)}')
   if echo "$ourl"|grep -q "get-pip.py";then
   #trying the suggested version
      set -eEo pipefail;trap 'f_err_h;exit 1' ERR   
      rm -f "${mytempdir}/get-pip.py"
      curl -sSL "${ourl}" -o "${mytempdir}/get-pip.py"
      python "$parms" || return 1
  fi    
   
}


f_inst_o () {
   #Install through OS package management
   if command -v apt 2>/dev/null;then
      apt update &>/dev/null && apt -y install $pkg &>/dev/null 
      dpkg -l $pkg &>/dev/null || return  1
   elif command -v yum &>/dev/null;then
      yum -y install $pkg &>/dev/null
      rpm -q $pkg || return 1
   elif command -v emerge &>/dev/null;then
      emerge "dev-python/pip" &>/dev/null
      grep -rw "dev-python/pip" /var/db/pkg/ &>/dev/null|| return  1
   else
      echo "Unsupported Linux distro"
      return 12
   fi 
}

trap 'f_err_h;exit 1' ERR
trap '' SIGINT
trap 'f_exit_h $ret' 0 15

echo "Installing pip..."

if [[ -n "${is_install_g}" ]];then 
   f_inst_g
   ret=$?
else
   f_inst_o
   ret=$?
fi 

if ! echo "$PATH"|grep -q '/usr/local/bin';then
    echo "Warning: /usr/local/bin is not in the PATH."
fi  
exit $ret
