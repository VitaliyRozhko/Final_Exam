#!/usr/bin/bash

while IFS=, read -r col1 col2 col3 col4 col5 col6; do
unset col3_new #reset values

#change to a capital letter in the first and last name
    for i in $col3; do
       if [ -z "$col3_new" ];then
           col3_new=${i^}
       else col3_new+=" ${i^}"
       fi
    done

#fill in the email field
    while IFS= read -r line; do
    if [[ "$line" == "$col3_new" ]]; then
	#check for identical first and last names and add ID to email
  	first=${col3:0:1}
        rest=$(echo $col3 | cut -d' ' -f2)
        col5=${first,}${rest,,}${col2}@abc.com
	break
    else    
        first=${col3:0:1}
        rest=$(echo $col3 | cut -d' ' -f2)
        col5=${first,}${rest,,}@abc.com
    fi
    done < <(cut -d, -f3 $1 | sort | uniq -di | sed -E 's/(\w)(\w*)/\U\1\L\2/g') #choose unique names and surnames

    echo "${col1},${col2},${col3_new},${col4},${col5},${col6}"
#for input: we send the file specified in the argument without the head line; to the output: save to a new csv file
done < <(tail -n +2 $1) > accounts_new.csv 

#add a header from the source csv file to the csv file
head1=($(head -n 1 $1))
sed -i -e '1i'${head1[@]}'' accounts_new.csv




