#!/usr/bin/env ruby
output = []
Dir.foreach('.') do |item|
  next if item == '.' or item == '..'
  if !item.start_with?("\.")
    output.push(item)
  end
end
# ソート
output = output.sort

output.each_with_index do |object, count|
  printf("%-24s",object)
  puts() if count%6==5
end
