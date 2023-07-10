# hobby-tracker

A hobby tracking application created with groupmate Skye Toral!  This program was designed with a command line interface in mind, and connects to a user's local database instance.  The database coding was done in MySQLWorkbench, and the main application code (Java-based) was completed in IntelliJ.  

Because this application is run in a relatively simple command line interface, users are expected to standardize their inputs and correctly order their tuples.  If this is not done correctly, data will etiher be inserted under incorrect columns or it will fail upon attempting to insert.  Messages are provided to the user, through the View class, detailing the exact order expected of them.  

Through the creation of various triggers and procedures, many of the necessary database operations are performed within the database itself.  The Java code functions more as user-interaction focused, rather than providing significant internal database functionality.  
