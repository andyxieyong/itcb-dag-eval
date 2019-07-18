#!/bin/bash
#!/bin/bash
contdir="`dirname \"$0\"`"
source ${contdir}/params.sh
source ${contdir}/funcs.sh

declare LOG=wl-save.log
declare START=$(date +%s)
declare TASKSETS=0

# False entrypoint
function main {
	report

	local n
	rm -f unsorted.util
	rm -f sorted.util

	TASKSETS=$(wc -l base.list | awk '{print $1}')
	begin_osect "WL_SAVE[$TASKSETS] "

	# printf "#%-14s %6s %6s %6s %6s %6s %6s %6s\n" \
	#        TASKNAME NOCOLL ARB MAXB MINP dCa dCb dCp > wl-delta.dat

	# local line
	# local c=0
	# while read -r line
	# do
	# 	wl_data $line >> wl-delta.dat
	# 	(( ++c ))
	# 	add_o "$c "
	# done < base.list
	# end_osect

	local ncsum=$(awk '{s+=$2} END {print s}' wl-delta.dat)
	local acsum=$(awk '{s+=$3} END {print s}' wl-delta.dat)
	local bcsum=$(awk '{s+=$4} END {print s}' wl-delta.dat)
	local pcsum=$(awk '{s+=$5} END {print s}' wl-delta.dat)		

	local ncavg=$(echo $ncsum / $TASKSETS | bc -l)
	local acavg=$(echo $acsum / $TASKSETS | bc -l)
	local bcavg=$(echo $bcsum / $TASKSETS | bc -l)	
	local pcavg=$(echo $pcsum / $TASKSETS | bc -l)		
	
	local asum=$(awk '{s+=$6} END {print s}' wl-delta.dat)
	local bsum=$(awk '{s+=$7} END {print s}' wl-delta.dat)
	local psum=$(awk '{s+=$8} END {print s}' wl-delta.dat)

	local aavg=$(echo $asum / $TASKSETS | bc -l)
	local bavg=$(echo $bsum / $TASKSETS | bc -l)	
	local pavg=$(echo $psum / $TASKSETS | bc -l)		

	local avgs=wl-avgs.dat
	printf "# Average workloads\n" > $avgs
	printf "%10s %6.2f\n" NoCollapse $ncavg >> $avgs
	printf "%10s %6.2f\n" Arbitrary $acavg >> $avgs
	printf "%10s %6.2f\n" Max-Ben. $bcavg >> $avgs
	printf "%10s %6.2f\n" Min-Pen. $pcavg >> $avgs

	local sum=wl-sum.dat
	printf "# Average workload savings\n" > $sum
	printf "%10s %6.2f\n" Arbitrary $aavg >> $sum
	printf "%10s %6.2f\n" Max-Ben. $bavg >> $sum
	printf "%10s %6.2f\n" Min-Pen. $pavg >> $sum
	
	local mins=$(min_elapsed $START)
	echo "Duration: $mins m Log: $LOG"
	
	return 0;
}

function report {
	echo "Creating base graphs with parameters:"
	echo -e "\tNodes:\t${NODES[@]} ${#NODES[@]}"
	echo -e "\tEdegeP:\t${EDGEP[@]}"
	echo -e "\tOjbs:\t${OBJS[@]}"
	echo -e "\tGrowF:\t${GROWF[@]}"	
	echo -e "\tUtils:\t${UTILS[@]}"
	echo -e "\tJobs:\t$JOBS"
}

function wl_data {
	local base=$1
	local aname=$(echo $base | sed s/\.dts/-a.dts/)
	local bname=$(echo $base | sed s/\.dts/-b.dts/)
	local pname=$(echo $base | sed s/\.dts/-p.dts/)		

	local nwl=$(sum_workload $base)
	local awl=$(sum_workload $aname)
	(( deltaa = nwl - awl ))
	local bwl=$(sum_workload $bname)
	(( deltab = nwl - bwl ))
	local pwl=$(sum_workload $pname)
	(( deltap = nwl - pwl ))

	local name=$(basename $base)
	printf "%-15s %6d %6d %6d %6d %6d %6d %6d\n" \
	       $name $nwl $awl $bwl $pwl $deltaa $deltab $deltap
}

function sum_workload {
	local file=$1

	local cmd="dts-print ../tasksets/$file"
	local v
	local wl=0
	while read -r v
	do
		local c=$(echo $v | grep -v \# | awk '{print $4}')
		(( wl += c ))
	done < <($cmd)

	echo $wl
}
	
main
exit $?
