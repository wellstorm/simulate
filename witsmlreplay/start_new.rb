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


opts.parse!

log_fragment =  IO.read $options[:log], 0, 200000
log_head = /(^.*)<\s*logData/.match(log_fragment)[1] + "</log></logs>"

uid_log =  /\suid\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]
uid_well =  /\suidWell\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]
uid_wellbore =  /\suidWellbore\s*=\s*['"]([^'"]+)['"]/.match(log_head)[1]

name_well =  /<\s*nameWell\s*>(.*)<\/nameWell\s*>/.match(log_head)[1]
name_wellbore =  /<\s*nameWellbore\s*>(.*)<\/nameWellbore\s*>/.match(log_head)[1]

puts "uidWell     : #{uid_well}"
puts "uidWellbore : #{uid_wellbore}"
puts "uid         : #{uid_log}"
puts "nameWell    : #{name_well}"
puts "nameWellbore: #{name_wellbore}"

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
url_well = "#{url_base}/well/#{@uid_well}"
url_wellbore = "#{url_well}/wellbore/#{uid_wellbore}"
url_log = "#{url_wellbore}/log/#{uid_log}"

puts "posting well to #{url_base}"
post well, url_base, $options[:user_name], $options[:password] 
puts "posting wellbore to #{url_well}"
post wellbore, url_well, $options[:user_name], $options[:password] 

puts "posting log header to #{url_wellbore}"
post log_head, url_wellbore, $options[:user_name], $options[:password] 



