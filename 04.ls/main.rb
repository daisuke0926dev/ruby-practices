#!/usr/bin/env ruby
# frozen_string_literal: true

# 定数
# 出力時、何列で表示するか
AMOUNT_PER_LINE = 6.0
# ------------------------------------------------
# カレントディレクトリのファイル,ディレクトリを取得します
# 返値: 名前の入った配列
# ------------------------------------------------
def search_cd_object
  output = []
  Dir.foreach('.') do |object|
    next if ['.', '..'].include?(object)

    output.push(object) if !object.start_with?("\.")
  end
  output
end

# ------------------------------------------------
# lsっぽく見えるように並び替えます
# 返却例: 00 04 07 10 13
# 　　　: 01 05 08 11 14
# 　　　: 02 06 09 12 15
# 　　　: 03
# 返値: 並び替え後の2次元配列
# ------------------------------------------------
def sort_like_ls(arr)
  # 返却用
  sorted_arr = []
  # 出力時の最大行数(例の場合は4)
  max_lines = (arr.size / AMOUNT_PER_LINE).ceil
  # 最大行数の列数(例の場合は1)
  max_line_columb_count = (arr.size % AMOUNT_PER_LINE).to_i

  # 以後、転置前の２次元配列を作成します。
  arr = arr.sort

  # 最大行数部分を構築
  max_line_columb_count.times do |line|
    sorted_arr.push(arr[(line * max_lines), max_lines])
  end

  # 最大行数部分以外を構築
  part_of_arr = arr[max_line_columb_count * max_lines..]

  # 表示が綺麗な長方形になる場合
  other_part_of_arr = if max_line_columb_count.zero?
                        make_divided_arr(part_of_arr, max_lines, 0)
                      else
                        # それ以外（最大行数部分とそれ以外で列数に差異1がある場合）
                        make_divided_arr(part_of_arr, max_lines - 1, max_line_columb_count)
                      end
  sorted_arr.concat(other_part_of_arr)

  # 転置処理
  # 各配列の要素数を最大要素数に合わせる
  sorted_arr.map! { |it| it.values_at(0...max_lines) }
  sorted_arr.transpose
end

# --------------------------------
# 配列を指定された数ごとに分割して返す
# --------------------------------
def make_divided_arr(part_of_arr, divid_count, max_line_columb_count)
  # 返却用
  divided_arr = []
  (AMOUNT_PER_LINE - max_line_columb_count + 1).to_i.times do |line|
    divided_arr.push(part_of_arr[(line * divid_count), divid_count])
  end
  divided_arr
end

# ----------------------
# メイン処理
# ----------------------
# カレントディレクトリのファイルやディレクトリを取得
pre_sort_output = search_cd_object

# lsらしく表示できるようにソート
sorted_output = sort_like_ls(pre_sort_output)

# 表示
sorted_output.each_with_index do |_object, i|
  sorted_output[i].each { |v| printf('%-24s', v) }
  puts
end
