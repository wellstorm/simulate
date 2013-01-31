
def traj_template uid_well, uid_wellbore, uid_traj, station
  template = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
    #{station}
  </trajectory>
</trajectorys>
EOF
end

def log_template uid_well, uid_wellbore, uid_log, vals_string
  template = <<EOF
  <logs xmlns=\"http://www.witsml.org/schemas/1series\" version="1.4.1.0">
  <log uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
    <logData>
    <mnemonicList>DEPTH,ILS,NPHI,ILD,GR,DPHI</mnemonicList>
    <unitList>ft,ohm,v/v,ohm,api,v/v</unitList>
      #{vals_string}
    </logData>
  </log>
</logs>
EOF

end


def mudlog_template uid_well, uid_wellbore, uid_mudlog, geology_interval
  template = <<EOF
<mudLogs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <mudLog uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_mudlog}">
    #{geology_interval}
  </mudLog>
</mudLogs>
EOF
end

