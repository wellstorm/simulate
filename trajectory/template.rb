
def traj_template uid_well, uid_wellbore, uid_traj, station
  template = <<EOF
<trajectorys xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <trajectory uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_traj}">
    #{station}
  </trajectory>
</trajectorys>
EOF
end

def log_template uid_well, uid_wellbore, uid_log, start_index, end_index, vals_string
  template = <<EOF
<logs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <log uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
    <indexType>measured depth</indexType>
<!--
    <startIndex uom='f'>#{start_index}</startIndex>
    <endIndex uom='f'>#{end_index}</endIndex>
-->
    <logCurveInfo uid='DEPTH'>
      <mnemonic>DEPTH</mnemonic>
      <unit>f</unit>
      <columnIndex>1</columnIndex>
    </logCurveInfo>
    <logCurveInfo uid='MTTV'>
      <mnemonic>MTTV</mnemonic>
      <unit>f</unit>
      <columnIndex>2</columnIndex>
    </logCurveInfo>
    <logCurveInfo uid='ROP'>
      <mnemonic>ROP</mnemonic>
      <unit>ft/h</unit>
      <columnIndex>3</columnIndex>
    </logCurveInfo>
    <logCurveInfo uid='SGR'>
      <mnemonic>SGR</mnemonic>
      <unit>gapi</unit>
      <columnIndex>4</columnIndex>
    </logCurveInfo>
    <logCurveInfo uid='VIBC'>
      <mnemonic>VIBC</mnemonic>
      <unit>cps</unit>
      <columnIndex>5</columnIndex>
    </logCurveInfo>
    <logData>
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

