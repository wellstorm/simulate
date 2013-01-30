There are two Ruby program in here: start.rb and replay.rb.

you need Ruby 1.92. Windows: http://rubyinstaller.org/downloads/. Others: http://www.ruby-lang.org/en/downloads/

The start.rb program initializes an empty log. You pass it the path to a WITSML log file on your local disk. The log should be time-based data. start.rb will use that one file to initialize, on the server, a well and wellbore containing that log. On the server, the log that start.rb creates will have no <data> in it yet -- just header info.

Here is how you can start the simulation:

ruby -I. start.rb -l log_L-499007-Time_segment001.xml -r https://wsp1.local/witsml/repository -u partner -p partner

Run that, then follow the instructions it prints out. It will tell you the command line to start the next phase, using replay.rb. Just copy that command line and execute it. Here's an example of the output it will print:

----------------------------------------------------------------------------------------
ruby -I. replay.rb -r https://wsp1.local/witsml/repository/well/DEMO1/wellbore/WB1/log/L-499007-Time -l "log_L-499007-Time_segment001.xml" -u partner -p partner
----------------------------------------------------------------------------------------


For reference here's the help message for start.rb

Usage: start_new.rb [options]
    -r, --url url                    URL of the repository
    -u, --username USER              HTTP user name (optional)
    -p, --password PASS              HTTP password (optional)
    -l, --log LOGFILE                Path to the log WITSML file
    -h, --help                       Show this message


