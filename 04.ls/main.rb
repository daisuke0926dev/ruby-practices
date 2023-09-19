#!/usr/bin/env ruby
# frozen_string_literal: true

AMOUNT_PER_LINE = 3.0

def search_cd_object
  output = []
  Dir.foreach('.') do |object|
    next if ['.', '..'].include?(object)

    output.push(object) if !object.start_with?("\.")
  end
  output
end

def sort_like_ls(arr)
  sorted_arr = []
  max_lines = (arr.size / AMOUNT_PER_LINE).ceil
  max_line_columb_count = (arr.size % AMOUNT_PER_LINE).to_i

  arr = arr.sort
  max_line_columb_count.times do |line|
    sorted_arr.push(arr[(line * max_lines), max_lines])
  end

  part_of_arr = arr[max_line_columb_count * max_lines..]

  other_part_of_arr = if max_line_columb_count.zero?
                        make_divided_arr(part_of_arr, max_lines, 0)
                      else
                        make_divided_arr(part_of_arr, max_lines - 1, max_line_columb_count)
                      end
  sorted_arr.concat(other_part_of_arr)

  sorted_arr.map! { |it| it.values_at(0...max_lines) }
  sorted_arr.transpose
end

def make_divided_arr(part_of_arr, divid_count, max_line_columb_count)
  divided_arr = []
  (AMOUNT_PER_LINE - max_line_columb_count + 1).to_i.times do |line|
    divided_arr.push(part_of_arr[(line * divid_count), divid_count])
  end
  divided_arr
end

pre_sort_output = search_cd_object

sorted_output = sort_like_ls(pre_sort_output)

sorted_output.each_with_index do |_object, i|
  sorted_output[i].each { |v| printf('%-24s', v) }
  puts
end
