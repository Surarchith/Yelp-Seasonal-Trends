# Yelp-Seasonal-Trends


ReadMe Instructions:

**The code has to be execute using a linux machine.
------------------------------------------------------------------------------------
Procedure 1:
-------------------------------------------------------------------------------------
Note: I have completely automated the process of transfering the files to the hadoop fs, and then uploading those files into the hdfs and then connecting to the spark-shell and running the commands.


2.The 'main.sh' is the script file which you will be executing. the "cluster.sh' file is automatically excuted when the first script file is called.

Note: Make sure you are currently connect to the utdallas intranet. (Either by getting connected to the comet net in the college or by using an VPN). ***PLease dont connect to utdallas intranet by any other ways or the script file will NOT work.


Instrutions to execute:
	1.Make sure all the files are in the same folder.
	2.Make sure you are connect to the campus net by using a vpn or by being present in the campus.
   Using command line
	3.cd to the current directory where files are stored.
	4.type sh main.sh
	5.Enter net id and password when asked.
   Now the script will get automatically executed and the files are downloaded to the hdfs dfs and then it enters into the spark mode.
	6.type 'hdfs dfs -ls' to get the .txt files in the hadoop fs. 

**The script will ask ur password muitple times, as each file time a file has to be uploaded, the cs6360 requests for a password.
** The script will automatically srt the spark-shell and start executing the spark commands. 
** Once the script execution is done, it will exit from the spark-shell. Scroll through your command promt screen for the results.

------------------------------------------------------------------------------------
Procedure 2
------------------------------------------------------------------------------------
If there is a problem with procedure 1. Use procedure 2.
	1.Copy the files manually into the 'cs6360 filesystem'.
	2.Enter spark shell by typing : 
		"spark-shell" 
	3.Copy commands from commands.txt file into the spark shell one by one to execute them.


***Note: The outputs maybe improper and may contain null and void values since only 0.1% of the data has been used in the sample files.
***Full version of the files can be downlaoded from "yelp.com".


Running the R script:

1.Once the Spark execution is done, some part of data is generated for the prupose of R. 
2. R is used for Time series analysis on the data for predicting the future seasonal trends.
3.Spark automatically saves data in the format of tables(commands not included for this sample data) which is given as input to R for the Trend analysis.
4."Trend Analysis.R" contains the code in R, and this can be execute using Rstudio.


***Note: For the hdfs part, as we have mentioned in the our presentaiton, we have created our own disturbed file system consisting of spark and other libraries.
***Thus all the storage and execution of the project has been deployed in a Distributed way.


