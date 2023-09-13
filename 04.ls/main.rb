#!/usr/bin/env ruby
Dir.foreach('.') do |item|
  next if item == '.' or item == '..'
  if !item.start_with?("\.")
    puts item
  end
end
