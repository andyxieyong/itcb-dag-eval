#!/bin/bash

function main {
	local ifile=$1 ; shift

	header
	local lastu=0
	local total=0
	local nc=0
	local ca=0
	local cb=0
	local cp=0
	while read line
	do
		local vals=($line)
		local util=${vals[0]}
		(( total += vals[1] ))
		(( nc += vals[2] ))
		(( ca += vals[3] ))
		(( cb += vals[4] ))
		(( cp += vals[5] ))

		local next=$(echo "($util - $lastu) >= 1" | bc -l)
		if [[ $next -eq 1 ]] ; then
			nc=$(echo "$nc" | bc -l)
			ca=$(echo "$ca" | bc -l)
			cb=$(echo "$cb" | bc -l)
			cp=$(echo "$cp" | bc -l)
			pline $lastu $total $nc $ca $cb $cp

			(( lastu += 1 ))
			(( total = nc = ca = cb = cp = 0 ))
		fi
	done < <(grep -v \# $ifile)
}

function header {
	printf "#%4s %6s %4s %4s %4s %4s\n" \
	       UTIL TOTAL NC CA CB CP
}

function pline {
	printf "%5s %6d %4d %4d %4d %4d\n" \
	       $*
}

main $@
exit $?
