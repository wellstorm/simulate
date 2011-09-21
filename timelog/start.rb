require 'optparse'
require 'post'

$options = {}

opts =OptionParser.new do |o|
  o.banner = "Usage: start_new.rb [options]"

  o.on("-r", "--url url", "URL of the repository") do |v|
    $options[:url] = v
  end
  o.on("-u", "--username USER", "HTTP user name (optional)") do |v|
    $options[:user_name] = v
  end
  o.on("-p", "--password PASS", "HTTP password (optional)") do |v|
    $options[:password] = v
  end
  o.on("-l", "--log LOGFILE", "Path to the log WITSML file") do |v|
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


opts.parse!

log_fragment =  IO.read $options[:log], 200000
log_head = /(.*)<\s*logData/m.match(log_fragment)[1] + "</log></logs>"

uid_log =  /\suid\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]
uid_well =  /\suidWell\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]
uid_wellbore =  /\suidWellbore\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]

name_well =  /<\s*nameWell\s*>(.*)<\/nameWell\s*>/.match(log_head)[1]
name_wellbore =  /<\s*nameWellbore\s*>(.*)<\/nameWellbore\s*>/.match(log_head)[1]
name_log =  /<\s*name\s*>(.*)<\/name\s*>/.match(log_head)[1]

puts "uidWell     : #{uid_well}"
puts "uidWellbore : #{uid_wellbore}"
puts "uid         : #{uid_log}"
puts "nameWell    : #{name_well}"
puts "nameWellbore: #{name_wellbore}"
puts "nam         : #{name_log}"

well=<<EOF
<wells xmlns="http://www.witsml.org/schemas/131">
  <well uid="#{uid_well}">
    <name>#{name_well}</name>
  </well>
</wells>
EOF


wellbore=<<EOF
<wellbores xmlns="http://www.witsml.org/schemas/131">
  <wellbore uidWell="#{uid_well}" uid="#{uid_wellbore}" >
    <nameWell>#{name_well}</nameWell>
    <name>#{name_wellbore}</name>
  </wellbore>
</wellbores>
EOF

url_base = $options[:url]
url_well = "#{url_base}/well/#{uid_well}"
url_wellbore = "#{url_well}/wellbore/#{uid_wellbore}"
url_log = "#{url_wellbore}/log/#{uid_log}"


puts "This progam will wipe any existing log that has the same uid."
puts "If the log with uid #{uid_log} exists, we are going to nuke it."
puts "Are you sure you are ready for as fresh, clean start with a "
print "new, empty log? If so, type 'yes': "

yes = gets.chomp

if yes != "yes"
  puts "Well, I'm glad I asked. Quitting now. No harm done."
  exit 0
end



puts "deleting well  #{url_well}"
puts "this can take 10 - 20 minutes if there is a lot of data to delete"
delete well, url_well, $options[:user_name], $options[:password] 
puts "posting well to #{url_base}"
begin
  post well, url_base + "/", $options[:user_name], $options[:password] 
rescue Net::HTTPServerException => e
  puts "ERROR #{e}"
  puts "EXPLANATION: Deletes happen asynchronously. So what's likely happened is"
  puts "you see an error 409 when we try to upload the well. Don't sweat it."
  puts "It means, Try again later. Give it a few minutes and try again."
  puts "It might take a few minutes to completely delete the well and its contents. "
  puts "Eventually, one of these tries will succeed. "
  puts "I'm quitting now."
  exit(1)
end
  puts "posting wellbore to #{url_well}"
post wellbore, url_well, $options[:user_name], $options[:password] 

puts "posting log header to #{url_wellbore}"
post log_head, url_wellbore, $options[:user_name], $options[:password] 

delete_state uid_well, uid_wellbore, uid_log

puts 
puts "It looks like everything succeeded."
puts "You have an empty log named \"#{name_well}\", in well \"#{name_well}\", wellbore \"#{name_wellbore}\"."
puts 
puts "Now run the following command to start the simulation:"
puts
puts "----------------------------------------------------------------------------------------"
puts "ruby -I. replay.rb -r #{url_log} -l \"#{$options[:log]}\" -u #{$options[:user_name]} -p #{$options[:password]}"
puts "----------------------------------------------------------------------------------------"
puts
puts "You can stop the simulation with Ctrl-C. You can continue it later, "
puts "picking up where you left off, by using the command above again."
puts "Only run this script, start.rb, when you want to make a clean start"
puts "with a new, empty log."


