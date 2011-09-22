require 'optparse'
require 'wmls'
require 'wmls'
require 'template'

url =  'https://wsp1.local:24443/witsml/services/store'

username = 'partner'
password = 'partner'

opts =OptionParser.new do |o|
  o.banner = "Usage: start_new.rb [options]"

  o.on("-r", "--url url", "URL of the repository") do |v|
    url = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    user_name = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    password = v
  end
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end

opts.parse!

uid_well= 'geologix-1'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_mudlog = 'mudlog-1'

md_last = ARGV[0].to_f || 0
verbose = false

mudlog_file = 'MudLog.witsml'
log_file = 'DepthLog.witsml'

wmls = Wmls.new url, username, password

mudlog_doc = REXML::Document.new(IO.read(mudlog_file))
log_doc = REXML::Document.new(IO.read(log_file))

mudlog_doc.elements.each('mudLogs/mudLog/geologyInterval') do |elt|
  md =  elt.elements['mdBottom'].text.to_f
  if md > md_last
    mudlog_depth =md
    $stderr.puts "mudlog depth #{mudlog_depth} > #{md_last}" if verbose
    mudlog_t = mudlog_template uid_well, uid_wellbore, uid_mudlog, elt.to_s    
    status, supp_msg = wmls.update_in_store mudlog_t

    if status != 1
      abort "Error updating mudlog: #{status} #{supp_msg}"
    end

    data_text = ""
    log_doc.elements.each('logs/log/logData/data') do |data|
      vals = data.text.split(',').map {|s| s.to_f}
      log_depth = vals[0]
      
      if log_depth > md_last && log_depth <= md
        $stderr.puts "log depth #{log_depth}, md #{md}" if verbose
        data_text = data_text + "\n    " + data.to_s      
      elsif log_depth > md && data_text.length  > 0
        log_t = log_template uid_well, uid_wellbore, uid_log, log_depth, log_depth, data_text
        $stderr.puts log_t if verbose
        status, supp_msg = wmls.update_in_store log_t
        if status != 1
          abort "Error updating log: #{status} #{supp_msg}"
        end
        break
      end
      
    end

    puts md  #our output is the last depth we did
    break
  end
end
