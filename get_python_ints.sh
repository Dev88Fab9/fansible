get_python_ints () {
	IFS=':' read -rapaths<<<"$PATH"

	for path in "${paths[@]}"; do
		IFS=$'\n' read -r -d '' -a my_python_ints < <( find "$path" -type f -iname "python*" && printf '\0' )
		if [ ${#my_python_ints[@]} -ne 0 ];then
			break
		fi  
	done  
	# now the array should not be empty..
	if [ ${#my_python_ints[@]} -eq 0 ];then
		return 1
	else
		# for my_python_int in "${my_python_ints[@]}";do
			# echo "${my_python_int}"
		# done    
		return 0
	fi
}
