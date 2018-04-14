# Punchthrough-ibeacon-example
Demonstration of using iBeacon in iOS in Swift 3.0

In this app, student can lookup course enrollment details in the classroom that configured with the ibeacon & iCloud automatically. 


# App screenshot
![foo](/mycourseintro.png "app photoes")


# 1.1.2.2	Switch button for Bean Detection Function
When Bluetooth is turned on and a Bean is found, a stackview will be appeared on the app which allows student to input their student id to look up the enrolled course information.

                                               

# 1.1.2.3	Alert Function 
Alert controller is implemented to check the status of Bluetooth and internet connection to ensure high quality of user experience.
                                                             

# 1.1.2.4	Write PublicDB Function 

Double tap gesture is implemented on the button to initialize the write PublicDB function.  RecordType could be input from this function.

  
 
# 1.1.2.5	Query Function 
Query by Predicate is written for 2 attributes to return enrolled information if record matching the location and student id or alert if not record matches.

                                                               
          
# 3rd Party Library
# Light Blue Bean

The bean being used in this app is the LightBlue Bean from PunchThrough

Library link: https://punchthrough.com/bean/docs/guides/building-an-app/v2-integrate-sdk/

# Punchthrough bean
![foo](/2732-04.jpg "lightblue bean")
