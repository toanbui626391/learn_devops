infile=$1
outfile=$2
echo $infile
while read line
do
    echo $line >> "$outfile"
done < "$infile" #inputfile