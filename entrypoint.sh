#!/bin/bash

# for timing the runtime of the script
start=`date +%s`


# mkdir /daycent
cd /daycent

# using getopts to parse out the command line options
while getopts s:n:m:l:e:f:g:i:j:r: flag

do
    case "${flag}" in
	# -s : schedule file name (without the .sch extension)
        s) sopt=${OPTARG};;
        # -n : binary monthly file name (without the .bin extension)
        n) nopt=${OPTARG};;
	# -m : if set, will download the binary monthly file from an s3 uri like s3://daycentinputs/inputs/monthly.bin
	m) mopt=${OPTARG};;
	# -l : Non-Daycent parameter -l means we want to run list100 on it afterwards
        l) list=${OPTARG};;
	# -e : extend file name, the binary file that will be read as a starting point (without the .bin extension)
	e) eopt=${OPTARG};;
	# -f : if set will download the binary extend file from an s3 uri like s3://daycentinputs/inputs/extend.bin
	f) fopt=${OPTARG};;
 	# -g : I have no idea why this is here, I think it may have been a legacy DayCent option?
	g) gopt=${OPTARG};;
	# -i : s3 uri link to the s3 file containing the input directory that has been compressed into a .tgz, tar.gz, or zip file. (for example: s3://psitestdata/inputs/inputs.tgz)
	i) iopt=${OPTARG};;
	# -j : job s3 bucket. a uri for an s3 bucket to collect the job inputs/outputs. will contain the individual runs from this job set (s3://daycent-jobs/jobs/1234)
	j) jopt=${OPTARG};;
	# -r run id (optional) : just a folder name to tack on to the job s3 uri to store job specific info
	r) ropt=${OPTARG};;
	\?) # invalid option
		echo "Invalid option: -$OPTARG" >&2 
		exit
		;;
    esac
done

echo "sopt = $sopt"
echo "nopt = $nopt"
echo "mopt = $mopt"
echo "list = $list"
echo "eopt = $eopt"
echo "fopt = $fopt"
echo "iopt = $iopt"
echo "jopt = $jopt"
echo "ropt = $ropt"



ddcent="/daycent/DayCent"
# echo "${ddcent}"

# assembling the command line options into a full command string
if [ -n "$sopt" ]; then
	ddcent="${ddcent} -s ${sopt}"
fi

if [ -n "$nopt" ]; then
        ddcent="${ddcent} -n ${nopt}"
fi

if [ -n "$eopt" ]; then
        ddcent="${ddcent} -e ${eopt}"
fi

if [ -n "$gopt" ]; then
        ddcent="${ddcent} -g ${gopt}"
fi

# set the s3 run directory to the eopch time
runid="run${start}"
# and then set it to what it was set to by the -r option if it is set
if [ -n "$ropt" ]; then
	runid="$ropt"	
fi

echo "runid = $runid"

# if the -i is set with the s3 filename then download it
if [ -n "$iopt" ]; then
	cd /daycent
	echo "Downloading input from s3 ${iopt}"
	time aws s3 cp ${iopt} .
	filename=$(echo "$iopt" | sed "s:.*/::")
	extension="${filename##*.}"
	if [ "$extension" == "tgz" ] || [[ "$filename" == *"tar.gz"* ]]; then
		echo "Found either tgz or tar.gz, decompressing $filename:"
		tar xzvf ${filename}
        	rm -rf ${filename}
	elif [ "$extension" == "zip" ]; then
		echo "found a zipfile, decompressing $filename:"
		unzip ${filename}
		rm -rf ${filename}
	fi

	dirname="${filename%.*}"
	# in case it was a tar.gz clip off that ".tar" bit
	dirname="${dirname%.*}"
	echo "cd'ing into ${dirname}"
	cd ${dirname}
fi

# if we set to download the monthly binary file go grab it from s3
if [ -n "$mopt" ]; then
	echo "downloading monthly file $mopt"
	aws s3 cp ${mopt} .
fi

# if we set to download the binary extend file go grab it from s3
if [ -n "$fopt" ]; then
	echo "downloading binary extend file $fopt"
        aws s3 cp ${fopt} .
fi


echo "Running ${ddcent}"

${ddcent}

# if the -l command line option was specified then run list100 and fix the output file format
if [ -n "$list" ]; then
	runlist="/daycent/list100 ${sopt} ${nopt} outvars.txt"
	echo "Running List100 with ${runlist}"
        ${runlist}
	# clean up the outfile
	echo "Cleaning up outfile"
	tr -s ' ' < ${sopt}.lis | tr ' ' ',' | sed 's/,//' > outfile.lis.csv
	# copy output to s3 job bucket
        aws s3 cp ${sopt}.lis ${jopt}/${runid}/${sopt}.lis
	aws s3 cp outfile.lis.csv ${jopt}/${runid}/outfile.lis.csv
	aws s3 cp /daycent/${dirname} ${jopt}/${runid}/outputs/ --recursive
fi

end=`date +%s`

runtime=$((end-start))
echo "Execution time is $runtime seconds"

