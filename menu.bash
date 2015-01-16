#!/bin/bash

#=======================================================
# Script Name:	User Menu
# By:		A.G.
# Date:		12/12/2015
# Purpose:	To print, add, search, and delete users
#=======================================================

#if the name of the file to be used with this script is given 
if [ ${#1} -gt 0 ]; then
	#create the file
	touch $1

	#assign name of file to $infile
	infile=$1
else
	#create file to store user information
	touch users.txt

	#variable for  user information file
	infile=./users.txt
fi


#if the name of the error file to be used with this script is given 
if [ ${#2} -gt 0 ]; then
	#assign name of file to $error
	error=$2
else
	#varialbe for error file
	error=./error.txt
fi

######################################################3

#used to center output on x axis
x_axis=`tput cols`

#used for cursor placement
t=28

#(no of columns + length of t) / 2 - lenth of t -1
#this formula ensures that menu is centered, regardaless of terminal width
column=`echo $(($(($(($x_axis+${t}))/2))-$((${t}-1))))`


############### PRINT FUNCTION ############################
print()
{

	#varialble to hold the longest first name, last name, & user name
	fnLength=`cut -d: -f1 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	lnLength=`cut -d: -f2 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	userLength=`cut -d: -f3 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	
	#variable to hold length of longest user name
	#passed as a parameters to AWK
	userWidth=`echo $((${#userLength}+5))`
	fnWidth=`echo $((${#fnLength}+5))`
	lnWidth=`echo $((${#lnLength}+0))`
	totalWidth=`echo $(($userWidth+$fnWidth+$lnWidth))`

	#centers cursor on row 26 & and bolds the output
	tput cup 26 $column
	tput bold
		
	#if $infile contains data:
	if [ -s $infile ]; then

		#used for the number of dashes under the header if the last name is under 4 letters
		if [ ${#lnLength} -lt 4 -o ${#fnLength} -lt 4 ]; then
			let totalWidth=$totalWidth+4-${#lnLength}
		fi
		
		#prints header information	
		#using bash variables to adjust width
		awk BEGIN'{printf "%-'"$userWidth"'s%-'"$fnWidth"'s%-'"$lnWidth"'s\n","USER","FIRST","LAST"}'
		
		#centers cursor on row 27
		tput cup 27 $column

		#prints dashes under the header. 
		# Will adjust the number of dashes according to the length of user information
		for ((i=0;i<$totalWidth;i++)); do
			echo -n "-"
		done		
		
		#turn bold off
		tput sgr0

	else
		#prints header information if $infile is empty
		awk BEGIN'{printf "%-9s%-10s%-9s\n","USER","FIRST","LAST"}'

		#centers cursor on row 27
		tput cup 27 $column

		#prints dashes 23 under the header. 
		for ((i=0; i<23; i++)); do
			echo -n "-"
		done		
		
		#turns bold off
		tput sgr0
	fi

		
	#sort user names and store in temp.txt; processed by AWK	
	sort -t: -k3 $infile > temp.txt
	
	#used for awk cursor placement in AWK
	row=28
	
	#used to control how many times the for loop runs
	let no_records=`cat $infile | wc -l`+1


	#print users in a well formatted report
	for (( i=1; i<$no_records; i++ )); do
		
		#centers cursor
		tput cup $row $column

		#using bash variables to adjust width
		awk -F: -v "j=$i" 'NR==j {printf "%-'"$userWidth"'s%-'"$fnWidth"'s%-'"$lnWidth"'s\n", $3,$1,$2}\
		' temp.txt

		#increament tput cup	
		row=$(($row+2))
		
	done
	
	#rm temporary file that was processed by AWK
	rm temp.txt

	#used for readAnswer's tput	
	let a="`cat $infile | wc -l`*2+30"

	#ask user to continue
	readAnswer $a
}

############## ADD NEW USER ################################
newUser()
{
	#center cursor on row 25
	tput cup 25 $column
	
	#read first and last name from user
	echo -n "Enter the first name: "
	read fname
	tput cup 26 $column
	echo -n "Enter the last name: "
	read lname

	#variables will hold first and last name converted to upper case
	fname=`echo $fname | tr '[:lower:]' '[:upper:]'`
	lname=`echo $lname | tr '[:lower:]' '[:upper:]'`


	#first letter of fname and first four letter of lname
	username="${fname:0:1}${lname:0:4}"
	
	#variable to hold how many users have the same username
	check=`cut -d: -f3 $infile | grep $username | wc -l`

	#appends a 1 if the username exists
	for (( start=0; $start < $check; start++ ))
	do
		username=${username}1 		
	done


	#append first, last, and username to users.txt
	echo $fname:$lname:$username >> $infile	

	#center cursor on row 29
	tput cup 29 $column

	#turn on highlighting
	tput smso

	echo  $fname $lname has been successfully added

	#turn off highlighting
	tput rmso

	#ask user to coninue
	readAnswer 33
}

############# SEARCH USER #######################
searchUser()
{

	#varialble to hold the longest first name, last name, & user name
	fnLength=`cut -d: -f1 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	lnLength=`cut -d: -f2 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	userLength=`cut -d: -f3 $infile | awk '{ if (length>x) {x=length; y=$0}} END {print y}'`
	
	#variable to hold length of longest user name
	#passed as a parameters to AWK
	userWidth=`echo $((${#userLength}+5))`
	fnWidth=`echo $((${#fnLength}+5))`
	lnWidth=`echo $((${#lnLength}+0))`
	totalWidth=`echo $(($userWidth+$fnWidth+$lnWidth))`

	#center cursor on row 25
	tput cup 25 $column

	#ask user to enter the fname of the user to search for
	echo -n "Enter the first name of the user: "
	read user

	#translate uppercase to lowercase
	user=`echo $user | tr '[:lower:]' '[:upper:]'`
	

	#stores how many $user's are found. direct stderr to $error
	test=`cut -d: -f1 $infile | grep -i -w $user 2>> $error| wc -l`
	
	#if $test > 0,(user was found) first name will print
	if [ $test -gt 0 ]
	then

		#center cursor on row 27
		tput cup 27 $column

		#turn on bold
		tput bold

		#print header information
		awk BEGIN'{printf "%-'"$userWidth"'s%-'"$fnWidth"'s%-'"$lnWidth"'s\n","USER","FIRST","LAST"}'

		#center cursor on row 28
		tput cup 28 $column

		#used for the number of dashes under the header if the last name is under 4 letters
		if [ ${#lnLength} -lt 4 -o ${#fnLength} -lt 4 ]; then
			let totalWidth=$totalWidth+4-${#lnLength}
		fi

		#prints dashes under the header. 
		# Will adjust the number of dashes according to the length of user information
		for ((i=0; i<$totalWidth; i++));do
			echo -n "-"
		done
		
		#turn on highlighting
		tput sgr0
		
		#used for tput cup
		row=29
		
		#number of users found, used by AWK command
		grep $user $infile > temp.txt

		#used to control for loop
		let no_records=`grep $user $infile | wc -l`+1
		
		#print a well formatted report
		for ((i=1; i< $no_records; i++));do 
			#place cursor in appropriate location
			tput cup $row $column ; 

			awk -F: -v "j=$i" 'NR==j {printf "%-'"$userWidth"'s%-'"$fnWidth"'s%-'"$lnWidth"'s", $3,$1,$2}' temp.txt ; 
			
			#increase row by 2
			row=$(($row+2)); 
		done
		
		#delete temporary file used by AWK		
		rm temp.txt

	else
		#center cursor on rown 28
		tput cup 28 $column

		#turn on highlighting
		tput smso
		echo -e "USER NOT FOUND!"

		#turn off highlighting
		tput rmso
	fi

	
	#used for readAnswer's tput cup. redirect stderr to $error
	let p="`cut -d: -f1 $infile | grep -i -w $user 2>> $error | wc -l`*2+32"
	
	#ask user to coninue
	readAnswer $p
}

################## DELETE USER ###########################
deleteUser()
{
	#center cursor on row 25
	tput cup 25 $column

	#ask and read the first name of the user do delete
	echo -n "Enter the first name of the user: "
	read user
	
	#translate uppercase to lowercase
	user=`echo $user | tr '[:lower:]' '[:upper:]'`

	#stores the number of user's found. redirect stderr to $error.
	test=`cut -d: -f1 $infile | grep -i -w $user 2>> $error | wc -l`
	

	#if $test > 0, (user was found) record will be deleted
	if [ $test -gt 0 ]
	then	
		#delete user and redirect output to temp.txt
		sed /$user/d $infile > temp.txt

		#copy temp.txt, which does not contains the user that was deleted, to $infile
		cp temp.txt $infile

		#rm temporary file
		rm temp.txt

		#center cursor on row 28
		tput cup 28 $column

		#turn on highlighting
		tput smso

		echo $test "instance(s) of" $user "has been deleted!"

		#turn off highlighting
		tput rmso
	else
		#center cursor on row 28
		tput cup 28 $column

		#turn on highlighting
		tput smso

		echo "USER NOT FOUND"

		#turn off highlighting
		tput rmso
	fi
	
	#ask user to continue
	readAnswer 32
}

############# EXIT ########################
exitMenu()
{
	#place cursor in appropriate location
	tput cup $1 $column

	#turn on highlighting
	tput smso

	echo EXITING...

	#turn off highlighting
	tput rmso

	#pause for 1 second and clear screen
	sleep 1;
	clear

	#exit script
	exit
}

################ READ ANSWER ###############################
readAnswer()
{
	#used to control while loop
	r=0
	
	#used for cursor placement
	p=$1

	while [ "$r" = 0 ]; do
	
		#place cursor in appropriate location	
		tput cup $p $column

		#turn bold on
		tput bold
		
		#prompt user to continue or not
		echo -n -e "Coninue [Y]es or [N]o: "

		#turn bold off
		tput sgr0

		#read answer to continue or not
		read i

		#convert answer to lowercase
		i=`echo $i | tr '[:upper:]' '[:lower:]'`

		#based on user input, script will either continue or quit
		case "$i" in
			y) mainMenu;;
			n) exitMenu $(($p+3));;
		esac
		
		#used for cursor placement
		let p=$p+2
	done
	
}

############# MAIN MENU #########################
mainMenu()
{

while_loop=y

while [ $while_loop == y ]; do 

	tput clear
	tput bold
	tput cup 14 $column; echo "============================"
	tput cup 15 $column; echo "            MENU"
	tput cup 16 $column; echo "============================"
	tput sgr0

	tput cup 17 $column; echo -e "(p, P) Print users info"
	tput cup 18 $column; echo -e "(a, A) Add new user"
	tput cup 19 $column; echo -e "(s, S) Search user"
	tput cup 20 $column; echo -e "(d, D) Delete user"
	tput cup 21 $column; echo -e "(x, X) Exit"
	tput cup 23 $column;echo -n -e "Enter your choice: "
	read choice

	case "$choice" in
	        [p,P]) print;;
	        [a,A]) newUser;;
		[s,S]) searchUser;;
		[d,D]) deleteUser;;
		[x,X]) exitMenu 25;;
	        *) tput cup 25 $column; tput smso; echo "INVALID CHOICE";tput rmso; sleep 1;;
	esac


done
}

########################################################

#mainMenu function invoked
mainMenu
#end of script
