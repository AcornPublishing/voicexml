The code for this chapter uses both Perl and MySQL, as described in the text. If you are unsure how to set up these two packages correctly, the following brief notes should be of some help.

If you have installed both Perl and MySQL from their distributions, you are more than halfway there. You also need Instant Saxon installed to make the code work correctly.  Just put all of the example files in the same directory, along with Instant Saxon in there, too; it's just a standalone binary file.

After you get MySQL installed, run its Windows admin program, which will be C:\MySQL\bin\winmysqladmin.exe (or something similar).  This will open a window.  Click on the "Database" tab.  Then right click on the machine name, and select "Create Database".  Name the database "voicexml".  Open up a shell window, and go to the directory where the example files are.  Enter "C:\Mysql\bin\mysql.exe voicexml", which will open up the database client. Then type "\. schema.sql".  This will create the tables and populate them. Finally, exit out of the database client with "\q".

Now, go back to the DOS/shell window and run "ppm".  This will install perl packages for you.  Type "install DBI" and enter.  Let it run.  Then type "install DBD::Mysql" and hit enter.  These lines are required in order to connect to the database from Perl.

Now you can run the perl script "export_myrubberbands.pl" which will generate a set of MyRubberbands ML files, and VoiceXML, HTML, and WML files for each of them with the stylesheets required.  As long as everything is in the same directory, there shouldn't be any path problems.
