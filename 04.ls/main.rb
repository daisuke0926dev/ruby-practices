#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_COLUMN = 3

# ファイル名ディレクトリ名を包括するので、コンテンツと称しています。
def current_directory_content_names(options)
  options[:option_lower_a] ? Dir.foreach('.').to_a : Dir.foreach('.').reject { |content_name| content_name.start_with?('.') }
end

def sort_vertically(content_names)
  sorted_content_names = []
  max_number_of_lines = (content_names.size / MAX_COLUMN.to_f).ceil
  limit_per_line = (content_names.size / max_number_of_lines.to_f).ceil
  amount_of_max_line_column = limit_per_line - ((max_number_of_lines * limit_per_line) % content_names.size)

  amount_of_max_line_column.times do |line|
    sorted_content_names.push(content_names[(line * max_number_of_lines), max_number_of_lines])
  end

  content_names_without_max_line_column = content_names[amount_of_max_line_column * max_number_of_lines..]

  # 転置後、縦に連番させるために、配列を区切ります
  divided_content_names_without_max_line_column =
    if amount_of_max_line_column.zero?
      make_divided_content_names(content_names_without_max_line_column, max_number_of_lines, 0, limit_per_line)
    else
      make_divided_content_names(content_names_without_max_line_column, max_number_of_lines - 1, amount_of_max_line_column, limit_per_line)
    end
  sorted_content_names.concat(divided_content_names_without_max_line_column)

  # 行・列の要素数が異なると転置できないため、nilで埋めています。
  filled_nil_sorted_content_names = sorted_content_names.map { |it| it.values_at(0...max_number_of_lines) }
  filled_nil_sorted_content_names.transpose
end

def make_divided_content_names(content_names_without_max_line_column, divid_count, amount_of_max_line_column, limit_per_line)
  divided_content_names = []
  (limit_per_line - amount_of_max_line_column + 1).times do |line|
    divided_content_names.push(content_names_without_max_line_column[(line * divid_count), divid_count])
  end
  divided_content_names
end

def parse_command_line_option
  option_lower_a = false
  option_reverse = false
  option_lower_l = false

  opt = OptionParser.new
  opt.on('-a', '--add', 'add an item') { option_lower_a = true }
  opt.on('-r', '--reverse', 'show reverse items') { option_reverse = true }
  opt.on('-l', '', 'show items detail') { option_lower_l = true }
  opt.parse(ARGV)
  { option_lower_a:, option_reverse:, option_lower_l: }
end

def sort_with_details(content_names)
  name_and_details = Array.new(content_names.size)
  content_names.each_with_index do |content_name, index|
    stat = File.stat("#{Dir.pwd}/#{content_name}")
    name_and_details[index] = [
      (stat.ftype[0]=="d" ? "d" : "-")+(format("%6d",stat.mode.to_s(8))[3,3].split('').map{translate_permission_number_to_text(_1.to_i)}.join),
      stat.nlink.to_s,
      Etc.getpwuid(stat.uid).name,
      Etc.getgrgid(stat.gid).name,
      stat.size.to_s.rjust(5),
      format("%2d",stat.mtime.strftime("%-m")),
      format("%2d",stat.mtime.strftime("%-d")),
      stat.mtime.strftime("%R"),
    content_name]
  end
  name_and_details
end

def translate_permission_number_to_text(permission_number)
  format("%03d", permission_number.to_s(2)).split('').map.with_index{_1.to_i.zero? ? "-" : "rwx"[_2] }
end

options = parse_command_line_option

content_names = current_directory_content_names(options)

simple_sorted_content_names = options[:option_reverse] ? content_names.sort.reverse : content_names.sort

if options[:option_lower_l]
  sorted_content_names_with_details = sort_with_details(simple_sorted_content_names)

  max_content_name_length = Array.new(sorted_content_names_with_details[0].size, 0)
  sorted_content_names_with_details.each do |sub_array|
    sub_array.each_with_index do |item, index|
      max_content_name_length[index] = [max_content_name_length[index], item.length].max
    end
  end

  sorted_content_names_with_details.each do |sorted_content_name_with_details|
    sorted_content_name_with_details.each_with_index { |v, i| print format("%-#{max_content_name_length[i] + 1}s", v) }
    puts
  end
else
  sorted_content_names = sort_vertically(simple_sorted_content_names)
  max_content_name_length = content_names.map(&:length).max
  sorted_content_names.each do |sorted_content_name|
    sorted_content_name.each { |v| print format("%-#{max_content_name_length + 1}s", v) }
    puts
  end
end
