#!/usr/bin/env ruby -w -I.
require 'optparse'
require 'rexml/document'
require 'wmls'

require 'template'

url =  'https://witsml.wellstorm.com/witsml/services/store'

username = 'YOUR.USER.NAME'
password = 'YOUR.PASSWORD'

uid_well= 'bhl-test-1'
uid_wellbore='wb-1'
uid_log = 'log-1'
uid_traj = 'traj-1'
md_last = ARGV[0].to_f || 0
verbose = false

traj_file = 'Trajectory.witsml'
log_file = 'Chalk-GR.witsml'


if username =~ /YOUR.*/ || password =~ /YOUR.*/
  abort 'FAIL you need to edit file sim.rb with your username and password.'
end

wmls = Wmls.new url, username, password

traj_doc = REXML::Document.new(IO.read(traj_file))
log_doc = REXML::Document.new(IO.read(log_file))

traj_doc.elements.each('trajectorys/trajectory/trajectoryStation') do |elt|
  md =  elt.elements['md'].text.to_f
  if md > md_last
    traj_depth =md
    $stderr.puts "traj depth #{traj_depth}" if verbose
    traj_t = traj_template uid_well, uid_wellbore, uid_traj, elt.to_s    
    status, supp_msg = wmls.update_in_store traj_t

    if status != 1
      abort "Error updating traj: #{status} #{supp_msg}"
    end

    data_text = ""
    log_doc.elements.each('logs/log/logData/data') do |data|
      vals = data.text.split(',').map {|s| s.to_f}
      log_depth = vals[0]
      
      if log_depth > md_last && log_depth <= md
        $stderr.puts "log depth #{log_depth}" if verbose
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


