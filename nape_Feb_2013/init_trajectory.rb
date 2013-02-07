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
  o.on("-k", "--uidTraj  UIDTRAJECTORY", "uid of the trajectory") do |v|
    $options[:uidTraj] = v
  end      
  o.on("-n", "--nameWell  NAMEWELL", "name of the well") do |v|
    $options[:nameWell] = v
  end
  o.on("-g", "--nameTraj NAMETRAJ", "name of the trajectory") do |v|
    $options[:nameTraj] = v
  end  
  
  o.on_tail("-h", "--help", "Show this message") do
    puts o
    exit
  end
end





opts.parse!


uid_well = $options[:uidWell]
uid_wellbore = "#{uid_well}-wb1"
uid_traj = $options[:uidTraj]
name_well = $options[:nameWell]
name_wellbore = name_well
name_traj = $options[:nameTraj]





deleteTrajTemplate=<<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
  </log>
</log>
EOF



url_base = $options[:url]
url_well = "#{url_base}/well/#{uid_well}"
url_wellbore = "#{url_well}/wellbore/#{uid_wellbore}"
url_traj = "#{url_wellbore}/trajectory/#{uid_traj}"

puts "uidWell     : #{uid_well}"
puts "uidWellbore : #{uid_wellbore}"
puts "uid         : #{uid_traj}"
puts "nameWell    : #{name_well}"
puts "nameWellbore: #{name_wellbore}"
puts "name        : #{name_traj}"
puts "url_wellbore: #{url_wellbore}"



traj = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
  <nameWell>#{name_well}</nameWell>
  <nameWellbore>#{name_wellbore}</nameWellbore>
  <name>#{name_traj}</name>
  <dTimTrajStart/>
  <dTimTrajEnd/>
  <mdMn uom="ft">13892</mdMn>
  <mdMx uom="ft">18610</mdMx>
  </trajectory>
</trajectorys>
EOF


puts "\nThis progam will wipe any existing trajectory that has the same uid."
puts "If the trajectory with: uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}'"
puts "uid='#{uid_traj}' exists, we are going to nuke it."
puts "Are you sure you are ready for as fresh, clean start with a "
print "new, empty trajectory? If so, type 'yes': "

yes = gets.chomp

if yes != "yes"
  puts "Well, I'm glad I asked. Quitting now. No harm done."
  exit 0
end



puts "deleting trajectory uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}' uid='#{uid_traj}'"
puts "this can take time if there is a lot of data to delete"
begin
  delete deleteTrajTemplate, url_traj, $options[:user_name], $options[:password] 
rescue
  puts '...that trajectory does not exist. Nothing to do.'
end


puts "posting trajectory to wellbore uidWell='#{uid_well} uid='#{url_wellbore}'"
post traj, url_wellbore, $options[:user_name], $options[:password] 

puts 
puts "It looks like everything succeeded."
puts "You have an empty trajectory uidWell='#{uid_well}' uidWellbore='#{uid_wellbore}' uid='#{uid_traj}' named \"#{name_traj}\", in well \"#{name_well}\", wellbore \"#{name_wellbore}\"."

