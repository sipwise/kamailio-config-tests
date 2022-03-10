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

function usage
{
  echo "Usage: reorder_tests_tt2.sh [-t] [-m git|mv] firstmessagenumber [displacement]"
  echo "Options:"
  echo -e "\th: this help"
  echo -e "\tm [git|mv]: select whether to use 'git move' or 'mv' while renaming"
  echo -e "\tt: dry run"
  echo "Args:"
  echo -e "\\tfirstmessagenumber: numer of the first testfile to be processed"
  echo -e "\\tdisplacement: displacement to add to the test filename (optional, considering 1 if not given)"
  echo
  echo "Examples:"
  echo -e "\\t\$ reorder_tests_tt2.sh 19 2"
  echo -e "\\t will take each testfile of the current directory with filename number >= 19 ( for example 0024_test.yml.tt2) and add 2"
  echo -e "\\t this script will rename the files like this:"
  echo -e "\\t ./0024_test.yml.tt2 -> ./0026_test.yml.tt2"
  echo -e "\\t ./0023_test.yml.tt2 -> ./0025_test.yml.tt2"
  echo -e "\\t ./0022_test.yml.tt2 -> ./0024_test.yml.tt2 "
  echo -e "\\t ... and so on until we reach ./0019_test.yml.tt2"
  echo -e "\\t"
  echo -e "\\t\$ reorder_tests_tt2.sh -m mv 19 2"
  echo -e "\\t   this comand will do the same but it will use mv rather than git mv"
  echo -e "\\t\$ reorder_tests_tt2.sh -t 19 2"
  echo -e "\\t   this comand will do the same but it will just preview what will be renamed and how without changing anything"
}

DRY_RUN=0
MODE="git"

while getopts 'hm:t' opt; do
  case $opt in
    t) DRY_RUN=1;;
	m) MODE=${OPTARG};;
    *) usage; exit 1;;
  esac
done

shift $((OPTIND - 1))

INI=$1
DISP=${2:-1}

case $# in
	1|2) ;;
	*) echo "Wrong number or argument s $#"; usage; exit 1;;
esac

if [[ "$DRY_RUN" == 1 ]]; then
	echo "Using dryrun"
fi

case "${MODE}" in
  mv) echo "Using ${MODE} for renaming";;
  git) MODE="git mv"; echo "Using ${MODE} for renaming";;
  *) echo "Error: mode ${MODE} unknown"
     usage
     exit 2;;
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
		if [[ "$DRY_RUN" == 1 ]]; then
			echo " rename ${tfile} into ${next_file}"
		else
			"${MODE}" "${tfile}" "${next_file}"
			log_info "OK ${num} => $next"
		fi
	else
		log_info "nothing to do with ${tfile}"
	fi
done