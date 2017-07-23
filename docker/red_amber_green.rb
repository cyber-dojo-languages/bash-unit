
lambda { |stdout,stderr,status|
  output = stdout + stderr
  return :amber if /value too great for base/.match(output)
  return :amber if /line (\d+): syntax error/.match(output)
  return :red   if /\.\.\. FAILURE/.match(output)
  return :green if /\.\.\. SUCCESS/.match(output)
  return :amber
}
