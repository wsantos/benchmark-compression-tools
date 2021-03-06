all_data=all_data.txt
sizes=sizes.txt
measures=measures.txt

rm $all_data
rm $sizes
rm $measures

for folder in artificial pseudo-real real; do
	for file in $folder/data/*.time; do

		algo=`cat $file | grep "Command being timed:" | cut -d'"' -f 2 | cut -d' ' -f1`
		f=`cat $file | grep "Command being timed:" | cut -d'"' -f2 | cut -d'/' -f3 | cut -d' ' -f1`

		if [ "$algo" = "bwt" ] || [ "$algo" = "cw-bwt" ]; then 
			RSS=`cat $file | grep "Maximum resident set size" | cut -d' ' -f 6`
			RSS=$((RSS-3000)) #correct: subtract (approximate) size taken by shared libraries
		else		
			RSS=`cat $file | grep "Size of the structures (KB):" | cut -d' ' -f 7`
		fi

		ftime=`cat $file | grep "Elapsed (wall clock)" | cut -d' ' -f 8`

		printf $algo"\t"$f"\t"$RSS"\t"$ftime"\n" >> $all_data

	done
done

#create file with sizes
for folder in artificial pseudo-real real; do
	for file in $folder/data/*.txt; do

		f=`echo $file | awk -F/ '{print $NF}'`
		s=`wc -c $file | cut -d' ' -f1`
		s=$((s/1024))	#convert to kB
		printf $f"\t"$s"\n" >> $sizes

	done
done

#create file with z and R
for folder in artificial pseudo-real real; do
	for file in $folder/data/*.txt; do

		f=`echo $file | awk -F/ '{print $NF}'`
		z=`cat $file.lz77_factors`
		R=`cat $file.bwt.runs | cut -d' ' -f6`
		printf $f"\t"$z"\t"$R"\n" >> $measures

	done
done


# ----------------------------------------- SPACE - KB

#print table header
printf "dataset"
printf "\tsize (KB)"
printf "\tz"
printf "\tR"

for t in `cat $all_data | cut -f1 | sort | uniq`; do #for all tools
	printf "\t"$t
done
printf "\n"

#print table content
for d in `cat $all_data | cut -f2 | sort | uniq`; do #for all datasets

	printf $d #print dataset

	d_size=`cat $sizes | grep $d | cut -f2` #dataset size (KB)

	z=`cat $measures | grep $d | cut -f2`
	R=`cat $measures | grep $d | cut -f3`

	printf "\t"$d_size"\t"$z"\t"$R

	for t in `cat $all_data | cut -f1 | sort | uniq`; do #for all tools
		
		t_size=`cat $all_data | grep -P ^"$t\t$d" | cut -f3`	#tool RAM consumption
		#t_size=$((t_size-3000))
		compression="-"		

		#Compute %compression. avoid errors with missing data
		if [ "$t_size" != "" ]; then 
			compression=`echo "scale=4;100*$t_size/$d_size" | bc`
		fi

		printf "\t"$t_size" ("$compression"%%)"

	done

	printf "\n"

done
