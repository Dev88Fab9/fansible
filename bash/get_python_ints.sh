#Get how many pythons we have in the PATH

get_python_ints () {
	IFS=':' read -rapaths<<<"$PATH"

	for path in "${paths[@]}"; do
	    [[ ! -d "$path" ]] && continue
		IFS=$'\n' read -r -d '' -a my_python_ints < <( find "$path" -type f -iname "python*" && printf '\0' )
		if [ ${#my_python_ints[@]} -ne 0 ];then
			break
		fi  
	done  
	# now the array should not be empty..
	if [ ${#my_python_ints[@]} -eq 0 ];then
		return 1
	else
		return 0
	fi
}
