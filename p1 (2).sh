#!/bin/bash
#kareem qutob 1211756 Hamza shaer 1211162
echo Welcome to our Medical Test Management System

unit(){
    local test=$1
    grep $test medicalTest.txt | cut -d';' -f3 | cut -d':' -f2
}

searchBystat(){
  local id=$1
  local st=$2
  grep "$id" medicalRecord.txt | grep $2
}
DeleteTest(){
  while true
    do
    echo enter patient id
    read id
    if ! valid_id "$id";
    then
      echo id must have seven digits
    else
      break
    fi
    done

    echo enter the number of the Test you want to delete
    grep $id medicalRecord.txt | cat -n

    while true
    do
    read line
    if grep $id medicalRecord.txt | cat -n | grep "^\s*$line\s" >/dev/null
    then
    break
    else
      echo there are no such line
    fi
    done


    oldrec=$( grep $id medicalRecord.txt | sed -n "${line}p" )
     grep -vF "$oldrec" medicalRecord.txt > temp && mv temp medicalRecord.txt
    echo record has been deleted succesfly
    Menu


}
retreiveAll(){
  local id=$1
  grep $1 medicalRecord.txt
}

AverageCal2() {
  # 0--> HBG , 1--> BGT , 2--> LDL , 3--> SBP , 4--> DBP
  declare -A summation
  declare -A count
  declare -A avg
  while IFS= read -r line; do
  test=$(echo "$line" | cut -d'(' -f2 | cut -d')' -f1)

  #lineNO=$(wc -l < "medicalTest.txt")
  if [ -z "${summation[$test]}" ]; then
    summation["$test"]=0.0
    count["$test"]=0.0
    avg["$test"]=0.0
  fi
  done < "medicalTest.txt"

  while read -r line; do
  Result=$(echo "$line" | cut -d' ' -f4 | tr -d ',')
  TestType=$(echo "$line" | cut -d' ' -f2 | tr -d ',')
  test=$(echo "$line" | cut -d':' -f2 | cut -d',' -f1 | xargs)

    summation["$test"]=$(echo "${summation["$test"]} + $Result" | bc)
    count["$test"]=$(echo "${count["$test"]} + 1.0" | bc)

    done < medicalRecord.txt

  # Calculate and print averages for every test
    for test in "${!summation[@]}"; do
    tname=$test
    if [ "$(echo "${count[$test]} > 0.0" | bc)" -eq 1 ]; then
      avg[$test]=$(echo "scale=2; ${summation[$test]} / ${count[$test]}" | bc)
      echo "Average value of ${tname} test: ${avg[$test]} $(unit "$test")"
    else
      echo "Test ${tname} has no records"
    fi
  done
  Menu

}




searchByDate(){
  local idt=$1
# take start Period
while true; do
echo "Enter the year for the beginning of the period:"
read year
    if ! [[ "$year" =~ ^[0-9]+$ ]]; then
echo "Year must be a number"
elif [ "$year" -gt 2024 ] || [ "$year" -lt 2000 ]; then
echo "Year must be between 2000 and 2024"
else
break
fi
  done

  while true; do
echo "Enter the month for the beginning of the period:"
read month
    if ! [[ "$month" =~ ^[0-9]+$ ]]; then
echo "Month must be a number"
elif [ "$month" -gt 12 ] || [ "$month" -lt 1 ]; then
echo "Month must be between 1 and 12"
else
break
fi
  done
Date1=$(combineDate "$year" "$month")

#take end Period
while true; do
echo "Enter the year for the end of the period:"
read year2
    if ! [[ "$year2" =~ ^[0-9]+$ ]]; then
echo "Year must be a number"
elif [ "$year2" -gt 2024 ] || [ "$year2" -lt 2000 ]; then
echo "Year must be between 2000 and 2024"
else
break
fi
  done

  while true; do
echo "Enter the month for the end of the period:"
read month2
    if ! [[ "$month2" =~ ^[0-9]+$ ]]; then
echo "Month must be a number"
elif [ "$month2" -gt 12 ] || [ "$month2" -lt 1 ]; then
echo "Month must be between 1 and 12"
else
break
fi
  done
Date2=$(combineDate "$year2" "$month2")

#year1 yaer2 handling
if [ "$year" -gt "$year2" ]; then
echo "Invalid period"
searchByDate "$idt"
elif [ "$year" -eq "$year2" ] && [ "$month" -gt "$month2" ]; then
echo "Invalid period"
searchByDate "$idt"
fi

# Extract start and end year and month
startYear=$(echo "$Date1" | cut -d'-' -f1 | tr -d ' ')
startMonth=$(echo "$Date1" | cut -d'-' -f2 | tr -d ' ' | sed 's/^0*//')
endYear=$(echo "$Date2" | cut -d'-' -f1 | tr -d ' ')
endMonth=$(echo "$Date2" | cut -d'-' -f2 | tr -d ' ' | sed 's/^0*//')

# Loop through the records that match the ID
grep "^$idt:" medicalRecord.txt | while read -r line; do
# Extract the date part (year and month) directly from the line using cut
date=$(echo "$line" | cut -d' ' -f3 | tr -d ',')

recordYear=$(echo "$date" | cut -d'-' -f1)
recordMonth=$(echo "$date" | cut -d'-' -f2 | sed 's/^0*//')

# Compare dates to check if within range
if { [ "$recordYear" -gt "$startYear" ] || { [ "$recordYear" -eq "$startYear" ] && [ "$recordMonth" -ge "$startMonth" ]; }; } &&
{ [ "$recordYear" -lt "$endYear" ] || { [ "$recordYear" -eq "$endYear" ] && [ "$recordMonth" -le "$endMonth" ]; }; }; then
# Print the entire line if it matches the criteria
echo "$line"
fi
done
}
patientAbnormal(){
    local id=$1

    lineArr=()
     while IFS= read -r line; do
        if echo "$line" | grep -q "$id"; then
            lineArr+=("$line")
        fi
    done < "medicalRecord.txt"



    echo patient abnoraml tests
    for line in "${lineArr[@]}"; do
      testName=$(echo "$line" | cut -d ':' -f2 | cut -d ',' -f1 | xargs)
      range=$(grep $testName medicalTest.txt | cut -d ';' -f2 | cut -d ':' -f2 | cut -d 'U' -f1)
      range1=$(echo "$range" | grep -oP '>\s*[0-9.]+' | cut -d '>' -f2 | xargs)
      range2=$(echo "$range" | grep -oP '<\s*[0-9.]+' | cut -d '<' -f2 | xargs)
        num=$(echo "$line" | cut -d ',' -f3)
        if [[ -n "$range1" ]]
        then
          if (( $(echo "$num < $range1" | bc -l) ))
          then
                    echo "$line"
                    continue
            fi
        fi
         if [[ -n "$range2" ]]
        then
          if (( $(echo "$num > $range2" | bc -l) ))
          then
                    echo "$line"
                    continue
            fi
        fi

    done
   searchByID "$1"

}
searchByID(){
  local idd=$1
  while true
  do
  searchMenu
  read choose
  case $choose in
    1)
      retreiveAll "$1"
      searchByID "$1"
        ;;
    2)patientAbnormal "$1"
\
        ;;
    3)searchByDate "$1"

        ;;
    4)
      while true
    do
      echo enter a status option
      statusMenu
      read op

      stat1=$(status "$op")
      if [ $stat1 == "err" ]
      then
        echo you must chose a number between 1-3
        statusMenu
        status
      else
      break
      fi
    done
    searchBystat "$idd" "$stat1"

        ;;
    5) Menu ;;
    *)
        echo invailid input chose from 1-4 please!!

        ;;

esac
done
}
searchMenu(){
echo __________________________________________________________________________________________
echo "Select an option:"
echo "1. Retrieve all patient tests"
echo "2. Retrieve all abnormal patient tests"
echo "3. Retrieve all patient tests in a given specific period"
echo "4. Retrieve all patient tests based on test status"
echo "5. Exit"
echo __________________________________________________________________________________________
}
statusMenu(){
    echo _________________________________________________________________________________________
    echo "Select the status:"
    echo "1. Pending"
    echo "2. Completed"
    echo "3. Reviewed"
    echo __________________________________________________________________________________________
}
status() {

    local op="$1"
    case "$op" in
        1)
           echo "pending";;

        2)
           echo "completed"
            ;;
        3)
            echo "reviewd"
            ;;
        *)
            echo "err"
            ;;
    esac
}
combineDate(){
  local input1=$1
  local input2=$2
  if [ $input2 -lt 10 ]
  then
  local combine="${input1}-0${input2}"
  echo "$combine"
  else
  local combine="${input1}-${input2}"
  echo "$combine"
  fi

}
isFP() {
  local in=$1
 if [[ "$in" =~ ^[0-9]+\.[0-9]+$ ]]; then
    return 0
  else
    return 1
  fi
}
valid_test(){
  # with the assumption that
  #  Systolic Blood Pressure  is SBP
  # Diastolic Blood Pressure is DBP
  local input="$1"
   if grep -qw "$input" medicalTest.txt; then
    return 1 # Test is valid
  else
    return 0  # Test is invalid
  fi
}
insertRec(){
  while true
    do
    echo enter patient id
    read id
    if ! valid_id "$id";
    then
      echo id must have seven digits
    else
      break
    fi
    done
  while true
    do
    echo enter test name by its three capitilized chars
    read testname
    if  valid_test "$testname"
    then
      echo test name is a 3 chars capitilized word
    else

      break
    fi
    done
     echo enter the date of the test

    while true
    do
    echo enter the year
    read year
    if ! [ "$year" -eq  "$year" ] 2>/dev/null # to check if it is a numeber
    then echo year must be between 2000-2024
    elif [ $year -gt 2024 -o $year -lt 2000 ]
    then echo year must be between 2000-2024
    else
    break
    fi
    done
    while true
    do
    echo enter a month
    read month
    if ! [ "$month" -eq "$month" ] 2>/dev/null # to check if it is a numeber
    then echo year must be between 1-12
    elif [ $month -gt 12 -o $month -lt 1 ]
      then
        echo month must be between 1-12
    else
      break
    fi
    done
    date=$(combineDate "$year" "$month")
    echo $date

    while true
    do
    echo enter a result
    read res
     if ! [[ "$res" =~ ^-?[0-9]+(\.[0-9]+)?$ ]];  # to check if it is not a number
    then echo result must be a floating point
    elif isFP "$res"
      then
        break
    else
      echo result must be a floating point
    fi
    done
    while true
    do
      echo enter a status option
      statusMenu
      read op

      stat=$(status "$op")
      if [ $stat == "err" ]
      then
        echo you must chose a number between 1-3
        statusMenu
        status
      else
      break
      fi
    done
    u=$(unit "$testname")
    echo $u
    newRec="${id}: ${testname}, ${date}, ${res},${u}, ${stat}"

    echo "$newRec" >> "medicalRecord.txt"
    echo record has been added to the records file
    Menu


}
valid_id(){
  local input=$1
  if [[ $input =~ ^[0-9]{7}$ ]]
  then
    return 0
  else
    return 1
  fi
}
UpdateTest(){
  while true
    do
    echo enter patient id
    read id
    if ! valid_id "$id";
    then
      echo id must have seven digits
    else
      break
    fi
    done

    echo enter the number of the Test you wnat to change
    grep $id medicalRecord.txt | cat -n

    while true
    do
    read line
    if grep $id medicalRecord.txt | cat -n | grep "^\s*$line\s" >/dev/null
    then
    break
    else
      echo there are no such line
    fi
    done

    grep $id medicalRecord.txt | cat -n | grep "^\s*$line\s"
    oldrec=$( grep $id medicalRecord.txt | sed -n "${line}p" )




     while true
    do
    echo enter a new result
    read res
     if ! [[ "$res" =~ ^-?[0-9]+(\.[0-9]+)?$ ]];  # to check if it is not a number
    then echo result must be a floating point
    elif isFP "$res"
      then
        break
    else
      echo result must be a floating point
    fi
    done
    cut1=$(echo "$oldrec" | cut -d',' -f1,2)
    cut3=$(echo "$oldrec" | cut -d',' -f4-)
    newRec="$cut1, $res, $cut3"
    grep -vF "$oldrec" medicalRecord.txt > temp && mv temp medicalRecord.txt
    echo "$newRec" >> "medicalRecord.txt"
    echo record has been modified succesfly
    Menu
}
abnormal(){
   while true
    do
    echo enter test name by its three capitilized chars
    read testname
    if  valid_test "$testname"
    then
      echo test name is a 3 chars capitilized word
    else

      break
    fi
    done
    range=$(grep $testname medicalTest.txt | cut -d ';' -f2 | cut -d ':' -f2 | cut -d 'U' -f1)
    lineArr=()
    while IFS= read -r line; do
        if echo "$line" | grep -q "$testname"; then
            lineArr+=("$line")
        fi
    done < "medicalRecord.txt"
     range1=$(echo "$range" | grep -oP '>\s*[0-9.]+' | cut -d '>' -f2 | xargs)

    range2=$(echo "$range" | grep -oP '<\s*[0-9.]+' | cut -d '<' -f2 | xargs)


    for line in "${lineArr[@]}"; do
        num=$(echo "$line" | cut -d ',' -f3)
        if [[ -n "$range1" ]]
        then
          if (( $(echo "$num < $range1" | bc -l) ))
          then
                    echo "$line"
                    continue
            fi
        fi
         if [[ -n "$range2" ]]
        then
          if (( $(echo "$num > $range2" | bc -l) ))
          then
                    echo "$line"
                    continue
            fi
        fi

    done
    Menu
}
Menu(){
  echo __________________________________________________________________________________________
  echo chose an option
  echo 1.Add new medical record
  echo 2.Search for test by ID
  echo 3.Search for unnormal tests
  echo 4.Average tests values
  echo 5.update an existing test
  echo 6.delete an existing test
  echo 7.exit
  echo __________________________________________________________________________________________
  read choice
  case $choice in
  1)insertRec
    Menu;;
  2)
    while true
    do
        echo inter id
        read newid
        if ! valid_id "$newid";
    then
      echo id must have seven digits
    else
      break
    fi

    done
    record=$(grep "$newid" medicalRecord.txt)
    if [ -n "$record" ]; then
    searchByID "$newid";
    else
        echo this patient doesnot exist
    fi
    Menu;;

  3)abnormal;;
  4)AverageCal2;;
  5)UpdateTest;;
  6)DeleteTest;;
  7) exit 0;;
  *)echo Invalid option eneter a number between 1-6
    Menu ;;
  esac

}
if [ $# -ne 0 ]
then
  echo please dont enter arguemnts
  exit 0
fi
Menu
