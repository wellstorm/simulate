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
  o.on("-t", "--traj LOGFILE", "Path to the trajectory WITSML file") do |v|
     $options[:traj] = v
   end         
   
  o.on("-d", "--start_depth STARTDEPTH", "Depth to start at") do |v|
     $options[:start_depth] = v
   end      
   
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end

opts.parse!

def process_log (wmls, log_doc, md_start, md_end, uid_well, uid_wellbore, uid_log)
  data_text = ""
  log_doc.elements.each('logs/log/logData/data') do |data|
      vals = data.text.split(',')
      log_depth = vals[0].to_f
      
      if log_depth > md_start && log_depth <= md_end
        data_text = data_text + "\n    " + data.to_s    
      elsif log_depth > md_end && data_text.length  > 0
        
        log_t = log_template uid_well, uid_wellbore, uid_log, data_text
        $stderr.puts "posting log data between ]#{md_start},#{md_end}]"
        status, supp_msg = wmls.update_in_store log_t
        if status != 1
          abort "Error updating log: #{status} #{supp_msg}"
        end
        break
      end
   end   
end


url=$options[:url]


uid_well = $options[:uidWell]
uid_wellbore = "#{uid_well}-wb1"
uid_log = $options[:uidLog]
username = $options[:username]
password = $options[:password]

log_file = $options[:log]
traj_file = $options[:traj]

md_start = $options[:start_depth].to_f || 0
$stderr.puts "start depth is #{md_start}"

verbose = false
wmls = Wmls.new url, username, password
log_doc = REXML::Document.new(IO.read(log_file))
traj_doc = REXML::Document.new(IO.read(traj_file))


traj_doc.elements.each('trajectorys/trajectory/trajectoryStation') do |elt|
  md_traj =  elt.elements['md'].text.to_f
  $stderr.puts "traj station depth #{md_traj}" if verbose
  if md_traj > md_start
    md_end = md_traj
    process_log(wmls,log_doc, md_start, md_end, uid_well, uid_wellbore, uid_log)
    puts md_end
    break
  end
end
