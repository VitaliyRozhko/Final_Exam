#!/usr/bin/bash

#form a header for testName
first=($(head -n 1 $1 | cut -d " " -f 2 ))
rest=($(head -n 1 $1 | cut -d " " -f 3 ))
head1=${first}" "${rest}

#create a json struct and store the header
out_js=$(jq -n --arg key1 "$head1" '{testName:$key1,tests:[],summary:{}}')

#fill fields tests
while IFS= read -r line_tests; do
    #compare string with expression for name
    if  [[ $line_tests =~ expecting(.*) ]]; then
      var=${BASH_REMATCH[0]} #save the match to a variable 
      name_tests=${var%,*}   #delete everything from the comma to the end of the variable
    fi
    #compare the string with the expression for status	
    if [[ $line_tests == *not* ]]; then status_tests=false
    else status_tests=true
    fi
    #compare the string with the expression for duration
    if [[ $line_tests =~ [0-9]{,2}ms ]]; then
       duration_tests=${BASH_REMATCH[0]} #save the match
    fi
    #convert variables to json format for tests field
    out_js=$(echo $out_js | jq --arg key1 "$name_tests" --arg key2 "$status_tests" --arg key3 "$duration_tests" '.tests += [{name:$key1,status:$key2,duration:$key3}]')

done< <(tail -n +3 $1 | head -n -2 ) #remove last and beginning lines

#fill in the summary fields
while IFS= read -r line_summary || [ -n "${line_summary}" ]; do
    #compare the string with the expression for success    
    if [[ $line_summary =~ ^[0-9]{,2} ]]; then
        success_sum=${BASH_REMATCH[0]} #save the match
    fi
    #compare the string with the expression for failed
    if [[ $line_summary =~ ,.[0-9]{,2} ]]; then
    	var=${BASH_REMATCH[0]} #save the match to a variable 
	failed_sum=${var:2}    #remove two characters from the left
    fi
    #compare the string with the expression for rating
    if [[ $line_summary =~ [0-9]{,2}.[0-9]{,2}% ]] || [[ $line_summary =~ [0-9]{,3}% ]]; then
	var=${BASH_REMATCH[0]} #save the match to a variable 
	rating_sum=${var%%%*}  #remove the percent sign
    fi
    #compare the string with the expression for duration
    if [[ $line_summary =~ [0-9]{,2}ms ]]; then
	duration_sum=${BASH_REMATCH[0]} #save the match
    fi
   #convert variables to json format for the success field
   out_js=$(echo $out_js | jq --arg key1 "$success_sum" --arg key2 "$failed_sum" --arg key3 "$rating_sum" --arg key4 "$duration_sum" '.summary += {success:$key1,failed:$key2,rating:$key3,duration:$key4}')

done< <(tail -n1 $1 ) #remove everything but the last line

#convert the resulting file with division by lines
echo $out_js | jq "." > output.json
