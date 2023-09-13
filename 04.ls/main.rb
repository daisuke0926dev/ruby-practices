#!/usr/bin/env ruby
# frozen_string_literal: true

# 定数
AMOUNT_PER_LINE = 6.0
# ------------------------------------------------
# カレントディレクトリのファイル,ディレクトリを取得します
# 返値: 名前の入った配列
# ------------------------------------------------
def search_cd_object
  output = []
  Dir.foreach('.') do |item|
    next if ['.', '..'].include?(item)

    output.push(item) if !item.start_with?("\.")
  end
  output
end

# ------------------------------------------------
# lsっぽく見えるように並び替えます
# 返却例: 00 04 07 10 13
# 　　　: 01 05 08 11 14
# 　　　: 02 06 09 12 15
# 　　　: 03
# 返値: 並び替え後の配列
# ------------------------------------------------
def sort_like_ls(arr)
  # 返却用
  sorted_arr = []
  arr = arr.sort

  # 出力時の最大行数(例の場合は4)
  max_lines = (arr.size / AMOUNT_PER_LINE).ceil

  # 最大列数の数(例の場合は1)
  max_columb_amount = (arr.size % AMOUNT_PER_LINE).to_i

  # 以後、転置前の２次元配列を作成します。
  # 最大行数部分を構築
  max_columb_amount.times do |line|
    sorted_arr.push(arr[(line * max_lines), max_lines])
  end

  part_of_arr = arr[max_columb_amount * max_lines..]
  # そのほかの部分を構築
  # 表示が綺麗な長方形になる場合
  if max_columb_amount.zero?
    (AMOUNT_PER_LINE + 1).to_i.times do |line|
      sorted_arr.push(part_of_arr[(line * max_lines), max_lines])
    end
  else
    # それ以外
    (AMOUNT_PER_LINE - max_columb_amount + 1).to_i.times do |line|
      sorted_arr.push(part_of_arr[(line * (max_lines - 1)), max_lines - 1])
    end
  end

  # 各配列の要素数を最大要素数に合わせる
  sorted_arr.map! { |it| it.values_at(0...max_lines) }
  sorted_arr.transpose
end

# ----------------------
# メイン処理
# ----------------------
pre_sort_output = search_cd_object

# lsらしく表示できるようにソート
sorted_output = sort_like_ls(pre_sort_output)

sorted_output.each_with_index do |_object, i|
  sorted_output[i].each { |v| printf('%-24s', v) }
  puts
end
