
lambda { |stdout,stderr,_status|
  return :red   if /\.\.\. FAILURE/.match(stdout) && stderr==''
  return :green if /\.\.\. SUCCESS/.match(stdout) && stderr==''
  return :amber
}
