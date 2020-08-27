#!/bin/bash

die()
{
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

log_info()
{
  echo "INFO: $*"
}

INI=$1
DISP=${2:-1}

case $# in
	1|2) ;;
	*) echo "Wrong number or arguments"; usage; exit 1;;
esac

last_file=$(printf "%04d_test.yml.tt2" "${INI}")

if ! [ -f "${last_file}" ] ; then
	die "can't find ${last_file}"
fi

find . -name '0*_test.yml.tt2' | sort -r | while read -r tfile ; do
	[[ ${tfile} =~ /0*([0-9]+)_test\.yml\.tt2 ]] || die "wtf"
	num=${BASH_REMATCH[1]}
	if [[ ${num} -ge ${INI} ]]; then
		(( next = "$num" + "$DISP" ))
		next_file=$(printf "%04d_test.yml.tt2" $next)
		if [ -f "${next_file}" ] ; then
			die "file ${next_file} already exist"
		fi
		git mv "${tfile}" "${next_file}"
		log_info "OK ${num} => $next"
	else
		log_info "nothing to do with ${tfile}"
	fi
done
