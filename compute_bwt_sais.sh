#compute all BWTs
for folder in artificial pseudo-real real; do
	for file in $folder/data/*.txt; do

		echo "processing file "$file
		/usr/bin/time -v bwt -b 512 $file $file.sais.bwt 2> $file.sais.bwt.time
		echo ""

	done
done
