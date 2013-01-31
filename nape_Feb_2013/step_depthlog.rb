require 'optparse'
require 'wmls'
require 'wmls'
require 'template'


$options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: start_we;;.rb [options]"

  o.on("-r", "--url url", "WMLS Store URL of the repository") do |v|
    $options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    $options[:username] = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    $options[:password] = v
  end
  o.on("-i", "--uidWell  UIDWELL", "uid of the well") do |v|
    $options[:uidWell] = v
  end    
  o.on("-k", "--uidLog  UIDLOG", "uid of the log") do |v|
    $options[:uidLog] = v
  end      
  o.on("-l", "--log LOGFILE", "Path to the log WITSML file") do |v|
     $options[:log] = v
   end      
  o.on("-d", "--start_depth STARTDEPTH", "Depth to start at") do |v|
     $options[:start_depth] = v
   end      
  o.on("-s", "--step_depth STEPDEPTH", "Step Depth to start (default is 10)") do |v|
     $options[:step_depth] = v
   end      
  
   
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end

opts.parse!

#url =  'https://artemis:8443/witsml/services/store'

url=$options[:url]
#log_fragment =  IO.read $options[:log], 200000
#log_head = /(.*)<\s*logData/m.match(log_fragment)[1] + "</log></logs>"

uid_well = $options[:uidWell]
uid_wellbore = "#{uid_well}-wb1"
uid_log = $options[:uidLog]
username = $options[:username]
password = $options[:password]

  log_file = $options[:log]

  step_depth = $options[:step_depth].to_f||10  
  md_start = $options[:start_depth].to_f || 0
  md_end = md_start+step_depth
$stderr.puts "start depth is #{md_start}"
$stderr.puts "end depth is #{md_end}"
  verbose = true
  wmls = Wmls.new url, username, password
  log_doc = REXML::Document.new(IO.read(log_file))
  data_text = ""

log_doc.elements.each('logs/log/logData/data') do |data|
  vals = data.text.split(',')
  log_depth = vals[0].to_f
  if log_depth >= md_start && log_depth < md_end
    $stderr.puts "log depth #{log_depth}" if verbose
    data_text = data_text + "\n    " + data.to_s    
  elsif log_depth >= md_end && data_text.length  == 0
    # log_depth starts higher than the current range,
    ## so set the start to log_depth
    md_start=log_depth
    md_end=md_start + step_depth
    $stderr.puts "skipping to start depth #{log_depth}" if verbose
    data_text = data_text + "\n    " + data.to_s    
  elsif log_depth >= md_end && data_text.length  > 0
    log_t = log_template uid_well, uid_wellbore, uid_log, data_text
    $stderr.puts log_t if verbose
    status, supp_msg = wmls.update_in_store log_t
    if status != 1
      abort "Error updating log: #{status} #{supp_msg}"
    end
    puts log_depth  #our output is the last depth we did
    break
  end
end
