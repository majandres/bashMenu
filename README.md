# bashMenu
Bash script application that displays all the knowledge gathered during my UNIX Operating Systems course.



1.  This is a bash script program to process a data file based on a menu shown to the user. 

The format of the data file is as follows...

     firstName:lastName:userName 

...where userName is composed of first letter of first name, and first 4 letters of the last name. The user will only enter the first and last name, and the script will create the username. If the two user names end up being the same, then the number 1 is attached to the end of the newest username already in the data file. Example:

 

    first name: daniel

    last name: nash

    user name will be DNASH

    

     first name: donna

     last name: nash

     user name will be DNASH1

 

     first name: donald

     last name: nash

     user name will be DNASH11

 

2.  The program will display a menu to the user. Every time the menu is shown to the user, the screen should be cleared and the menu should appear somewhere in the middle of the screen.
 


3.  If the user selects the print option, then the program should:

  a.  Show first userName, then firstName, and finally lastName of each user in the data file in a nicely formatted way (use space in between each column).

  b.  The output has to be sorted based on the user name and all in capital letters.



4.  If the user selects the search option

  a.  The search will be based on the first name and give all the information of the users with the matching first name..

  b.  Print in a nicely formatted way (use space in between the columns)

  c.  The user can enter the name to search in any capitalization, but the program should finds it irrespective of capitalization.

 

5.  If the user selects the new user option, then:

  a.  The program will add a new user to the end of the data file by asking the first name and last name of the user and

  b.  by creating the appropriate username for the user.

  c.  If the username already exists in the data file, you should add number 1 to the end of newest username in the data filel

  d.  The program also converts the first name, last name and username all CAPITAL LETTERS before adding the new record to the data file, no matter what capitalization the user used.

 

6.  If the user selects delete option, the program will:

  a.  Ask the first name of the user to be deleted from the data file and then

  b.  Delete all the matching records

  c.  Note that, the user can enter the first name in any capitalization, the program will delete any matching records.
