
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
<logs xmlns="http://www.witsml.org/schemas/131" version="1.3.1.1">
  <log uidWell="#{uid_well}" uidWellbore="#{uid_wellbore}" uid="#{uid_log}">
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
      <data>#{vals_string}</data>
    </logData>
  </log>
</logs>
EOF

end
