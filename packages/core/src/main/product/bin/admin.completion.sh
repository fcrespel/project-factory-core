_@{product.id}_admin() {
	local cur

	COMPREPLY=()
	_get_comp_words_by_ref cur

	if [ $COMP_CWORD -eq 1 ]; then
		COMPREPLY=( $( compgen -W "$(find '@{product.bin}/tools.d' -name '*.sh' -printf '%f\n' | sed 's#\.sh$##g' | sort)" -- "$cur" ) )
	fi
}
complete -F _@{product.id}_admin -o filenames @{product.id}-admin
