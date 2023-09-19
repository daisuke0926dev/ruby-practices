#!/usr/bin/env ruby
# frozen_string_literal: true

AMOUNT_PER_LINE = 3

# ファイル名ディレクトリ名を包括するので、コンテンツと称しています。
def current_directory_content_names
  Dir.foreach('.').reject do |content_name|
    content_name.start_with?("\.")
  end
end

def sort_like_ls(arr)
  sorted_arr = []
  max_lines = (arr.size / AMOUNT_PER_LINE.to_f).ceil
  max_line_columb_count = (arr.size % AMOUNT_PER_LINE)

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
  (AMOUNT_PER_LINE - max_line_columb_count + 1).times do |line|
    divided_arr.push(part_of_arr[(line * divid_count), divid_count])
  end
  divided_arr
end

content_names = current_directory_content_names
max_content_name_length = content_names.map(&:length).max
sorted_content_names = sort_like_ls(content_names)

sorted_content_names.each do |sorted_content_name|
  sorted_content_name.each { |v| print "%-#{max_content_name_length+1}s" % v }
  puts
end
