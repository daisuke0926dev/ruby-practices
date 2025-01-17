#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_COLUMN = 3
FILE_TYPE = {
  'fifo' => 'p',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'blockSpecial' => 'b',
  'file' => '-',
  'link' => 'l',
  'socket' => 's'
}.freeze

# ファイル名ディレクトリ名を包括するので、コンテンツと称しています。
def current_directory_content_names(options)
  options[:option_show_hidden_files] ? Dir.foreach('.').to_a : Dir.foreach('.').reject { |content_name| content_name.start_with?('.') }
end

def convert_to_table(content_names)
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
  option_show_hidden_files = false
  option_reverse = false
  option_detailed_listing = false

  opt = OptionParser.new
  opt.on('-a', '--all', 'do not ignore entries starting with .') { option_show_hidden_files = true }
  opt.on('-r', '--reverse', 'reverse order while sorting') { option_reverse = true }
  opt.on('-l', '', 'use a long listing format') { option_detailed_listing = true }
  opt.parse(ARGV)
  { option_show_hidden_files:, option_reverse:, option_detailed_listing: }
end

def add_file_stats(content_names)
  total_block_size = 0
  detailed_contents = Array.new(content_names.size)

  content_names.each_with_index do |content_name, index|
    file_stat = file_stat(content_name)
    detailed_contents[index] = build_detailed_content(file_stat, content_name)
    total_block_size += file_stat.blocks
  end

  [detailed_contents, total_block_size]
end

def file_stat(content_name)
  File.lstat(File.join(Dir.pwd, content_name))
end

def build_detailed_content(file_stat, content_name)
  [
    file_type(file_stat) + file_permission(file_stat),
    file_stat.nlink.to_s,
    Etc.getpwuid(file_stat.uid).name,
    Etc.getgrgid(file_stat.gid).name,
    file_stat.size.to_s.rjust(5),
    file_stat.mtime.strftime('%-m').rjust(2),
    file_stat.mtime.strftime('%-d').rjust(2),
    file_stat.mtime.strftime('%R'),
    file_type(file_stat) == 'l' ? "#{content_name} -> #{File.readlink(File.absolute_path(content_name))}" : content_name
  ]
end

def file_type(file_stat)
  FILE_TYPE[file_stat.ftype]
end

def file_permission(file_stat)
  format('%6d', file_stat.mode.to_s(8))[3, 3].chars.map { |num| translate_permission_number_to_text(num.to_i) }.join
end

def translate_permission_number_to_text(permission_number)
  binary_representation = format('%03d', permission_number.to_s(2))
  binary_representation.chars.map.with_index { |bit, index| bit.to_i.zero? ? '-' : 'rwx'[index] }.join
end

def display_contents_with_details(simple_sorted_content_names)
  sorted_content_names_with_details, block_size = add_file_stats(simple_sorted_content_names)
  max_lengths = calculate_max_lengths(sorted_content_names_with_details)

  puts("total #{block_size}")
  sorted_content_names_with_details.each do |items|
    items.each_with_index do |item, index|
      print format("%-#{max_lengths[index] + 1}s", item)
    end
    puts
  end
end

def calculate_max_lengths(sorted_content_names_with_details)
  max_lengths = Array.new(sorted_content_names_with_details[0].size, 0)

  sorted_content_names_with_details.each do |items|
    items.each_with_index do |item, index|
      max_lengths[index] = [max_lengths[index], item.length].max
    end
  end

  max_lengths
end

options = parse_command_line_option
content_names = current_directory_content_names(options)
simple_sorted_content_names = options[:option_reverse] ? content_names.sort.reverse : content_names.sort
if options[:option_detailed_listing]
  display_contents_with_details(simple_sorted_content_names)
else
  sorted_content_names = convert_to_table(simple_sorted_content_names)
  max_content_name_length = content_names.map(&:length).max
  sorted_content_names.each do |sorted_content_name|
    sorted_content_name.each { |v| print format("%-#{max_content_name_length + 1}s", v) }
    puts
  end
end
