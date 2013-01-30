require 'optparse'
require 'post'

$options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: start_we;;.rb [options]"

  o.on("-r", "--url url", "URL of the repository") do |v|
    $options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    $options[:user_name] = v
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
  o.on("-n", "--nameWell  NAMEWELL", "name of the well") do |v|
    $options[:nameWell] = v
  end
  o.on("-g", "--nameLog NAMELOG", "name of the time log") do |v|
    $options[:nameLog] = v
  end  
  
  o.on("-l", "--log LOGFILE", "Path to the time log WITSML file") do |v|
     $options[:log] = v
   end      
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end

def delete_state (uid_well, uid_wellbore, uid_log)
  begin
    File.delete ".witsml-replay/#{uid_well}.#{uid_wellbore}.#{uid_log}"
  rescue
  end

end

def replace_log_object_text(s, uid_well, uid_wellbore, uid_log, name_well, name_wellbore, name_log)
  s["@UID_WELL@"] = uid_well
  s["@NAME_WELL@"] = name_well
  s["@UID_WELLBORE@"] = uid_wellbore
  s["@NAME_WELLBORE@"] = name_wellbore    
  s["@UID_TIME_LOG@"] = uid_log
  s["@NAME_TIME_LOG@"] = name_log                  
end

opts.parse!

log_fragment =  IO.read $options[:log], 200000
log_head = /(.*)<\s*logData/m.match(log_fragment)[1] + "</log></logs>"

uid_well = $options[:uidWell]
uid_wellbore = "#{uid_well}-wb1"
uid_log = $options[:uidLog]
name_well = $options[:nameWell]
name_wellbore = name_well
name_log = $options[:nameLog]





deleteLogTemplate=<<EOF
<logs xmlns="http://www.witsml.org/schemas/131">
  <log uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
  </log>
</log>
EOF



url_base = $options[:url]
url_well = "#{url_base}/well/#{uid_well}"
url_wellbore = "#{url_well}/wellbore/#{uid_wellbore}"
url_log = "#{url_wellbore}/log/#{uid_log}"

puts "uidWell     : #{uid_well}"
puts "uidWellbore : #{uid_wellbore}"
puts "uid         : #{uid_log}"
puts "nameWell    : #{name_well}"
puts "nameWellbore: #{name_wellbore}"
puts "name        : #{name_log}"
puts "url_wellbore: #{url_wellbore}"


replace_log_object_text(log_head, uid_well, uid_wellbore, uid_log, name_well, name_wellbore, name_log)

puts "Log head is:\n #{log_head}"

puts "\nThis progam will wipe any existing log that has the same uid."
puts "If the log with: uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}'"
puts "uid='#{uid_log}' exists, we are going to nuke it."
puts "Are you sure you are ready for as fresh, clean start with a "
print "new, empty log? If so, type 'yes': "

yes = gets.chomp

if yes != "yes"
  puts "Well, I'm glad I asked. Quitting now. No harm done."
  exit 0
end


delete_state uid_well, uid_wellbore, uid_log


puts "deleting log uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}' uid='#{uid_log}'"
puts "this can take time if there is a lot of data to delete"
begin
  delete deleteLogTemplate, url_log, $options[:user_name], $options[:password] 
rescue
  puts '...that log does not exist. Nothing to do.'
end


puts "posting log header to wellbore uidWell='#{uid_well} uid='#{url_wellbore}'"
post log_head, url_wellbore, $options[:user_name], $options[:password] 

puts 
puts "It looks like everything succeeded."
puts "You have an empty log uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}' uid='#{uid_log}' named \"#{name_log}\", in well \"#{name_well}\", wellbore \"#{name_wellbore}\"."
puts 
puts "Now you can run the following command to start the simulation:"
puts
puts "----------------------------------------------------------------------------------------"
puts "ruby -I. replay.rb -r #{url_log} -l \"#{$options[:log]}\" -u #{$options[:user_name]} -p #{$options[:password]}"
puts "----------------------------------------------------------------------------------------"
puts
puts "You can stop the simulation with Ctrl-C. You can continue it later, "
puts "picking up where you left off, by using the command above again."
puts "Only run this script, start.rb, when you want to make a clean start"
puts "with a new, empty log."


