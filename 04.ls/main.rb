#!/usr/bin/env ruby
output = []
Dir.foreach('.') do |item|
  next if item == '.' or item == '..'
  if !item.start_with?("\.")
    output.push(item)
  end
end
puts(output.sort)
