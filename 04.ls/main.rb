#!/usr/bin/env ruby
# frozen_string_literal: true

# ファイル名ディレクトリ名を包括するので、コンテンツと称しています。
def current_directory_content_names
  Dir.foreach('.').reject do |content_name|
    content_name.start_with?('.')
  end
end

def vertical_sort(content_names)
  sorted_content_names = []
  # 4つ表示時のみ2行で折り返し、それ以外はMAX3行で折り返すので。
  limit_per_line = content_names.size==4 ? 2 : 3
  max_number_of_lines = (content_names.size / limit_per_line.to_f).ceil
  amount_of_max_line_column = (content_names.size % limit_per_line)

  simple_sorted_content_names = content_names.sort
  amount_of_max_line_column.times do |line|
    sorted_content_names.push(simple_sorted_content_names[(line * max_number_of_lines), max_number_of_lines])
  end

  content_without_max_line_column = simple_sorted_content_names[amount_of_max_line_column * max_number_of_lines..]

  # 転置後、縦に連番させるために、配列を区切ります
  divided_content_without_max_line_column = if amount_of_max_line_column.zero?
                                              make_divided_content_names(content_without_max_line_column, max_number_of_lines, 0, limit_per_line)
                                            else
                                              make_divided_content_names(content_without_max_line_column, max_number_of_lines - 1, amount_of_max_line_column, limit_per_line)
                                            end
  sorted_content_names.concat(divided_content_without_max_line_column)

  # 行・列の要素数が異なると転置できないため、nilで埋めています。
  filled_nil_sorted_content_names = sorted_content_names.map { |it| it.values_at(0...max_number_of_lines) }
  filled_nil_sorted_content_names.transpose
end

def make_divided_content_names(content_without_max_line_column, divid_count, amount_of_max_line_column, limit_per_line)
  divided_content_names = []
  (limit_per_line - amount_of_max_line_column + 1).times do |line|
    divided_content_names.push(content_without_max_line_column[(line * divid_count), divid_count])
  end
  divided_content_names
end

content_names = current_directory_content_names
max_content_name_length = content_names.map(&:length).max
sorted_content_names = vertical_sort(content_names)

sorted_content_names.each do |sorted_content_name|
  sorted_content_name.each { |v| print format("%-#{max_content_name_length + 1}s", v) }
  puts
end
