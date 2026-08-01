#!/usr/bin/env bash
printf "test\tscript\ttime\n" > timings.tsv
timer() {
    real=$({ time "$@"; } 2>&1 >/dev/null | 
	awk '/real/ {
            split($2, t, "m")
            gsub("s", "", t[2])
            print t[1] * 60 + t[2]}')
	script=$(echo "$2" | awk -F'/' '{print $NF}')
	printf "\t%s\t%s\n" "$script" "$real"
}

tail -n +6 test.sh | head -n -3 | while read -r line; do
    if [[ "$line" =~ ^echo ]]; then
        t="${line#echo }"
        t="${t#\"}"         
        t="${t%\"}"         
        test="${t#...}" 
        echo "running $test"
        continue
    fi
    printf "%s" "$test" >> timings.tsv
    timer $line >> timings.tsv
done
