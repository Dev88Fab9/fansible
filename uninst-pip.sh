#!/bin/bash

f_usage () {

cat << EOS
    Remove the pip, pip2 or pip3 package
    USAGE:
      ${0} -u {1,2,3} [ -f ] [ -d ]
      
      Where
        -u {1,2,3}         => uninstall pip, pip2 or pip3
        -d                 => enable debugging
        -f                 => to provide if you are root
      
      Example:
         ${0} -u 1  -f -d 
EOS
    exit
}
echo 
if [[ $# -lt 2 || $# -gt 3 ]];then  
    f_usage
fi  

while getopts dfhu: OPT
do
  case "${OPT}" in
        d)
          is_debug=0
          set -x;
          PS4='+${LINENO}:'
          ;;
        u)
          case "${OPTARG}" in
              "1") cmd="pip";;
              "2") cmd="pip2";;     
              "3") cmd="pip3";;
              *)   f_usage;;
          esac
          ;;
        f)
          is_force="yes";;
        h)
          f_usage
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



[[ $(uname) != "Linux" ]] && exit 12

echo "Unstalling pip..."
if [[ $(id -u) -eq 0 && $is_force != "yes" ]];then
    echo "Root user and no force (-f) option provided. Exiting"
    exit 5
elif [[ $(id -u) -eq 0 &&  $is_force == "yes" ]];then   
    echo "Warning! It is not recommended to uninstall  pip as root."
    echo "Press CTRL+C in 10 seconds to abort."
    sleep 10
fi

 
trap 'f_err_h;exit 1' ERR
trap '' SIGINT
trap 'f_exit_h $ret' 0 15

echo "y"|$cmd uninstall $cmd || exit 1  
exit 0
