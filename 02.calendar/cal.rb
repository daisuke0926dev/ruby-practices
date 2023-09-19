#!/usr/bin/env ruby
require 'optparse'
require 'date'

# ----------------------------------------------
# コマンドラインオプションで年月を受け取ります。(省略可)
# 返値：ハッシュ["year":yyyy, "month":mm(0埋め無し)]
# ----------------------------------------------
def get_show_ym
  ret_date = { 'year' => Time.now.year.to_i, 'month' => Time.now.month.to_i }
  opt = OptionParser.new
  # 年の指定
  opt.on('-y', '--year [ITEM]', 'select year') do |param_year|
    ret_date['year'] = param_year.to_i if !param_year.nil?
    # パラメータチェック
    if ret_date['year'] < 1970 || ret_date['year'] > 2100
      puts('年の指定に誤りがあります。')
      exit
    end
  end

  # 月の指定
  opt.on('-m', '--month [ITEM]', 'select month') do |param_month|
    ret_date['month'] = param_month.to_i if !param_month.nil?
    # パラメータチェック
    if ret_date['month'] < 1 || ret_date['month'] > 12
      puts('月の指定に誤りがあります。')
      exit
    end
  end
  opt.parse(ARGV)

  # 返値
  ret_date
end

#--------------------------------
# メイン処理
#--------------------------------
# 表示対象年月を取得
show_ym = get_show_ym
show_year = show_ym['year']
show_month = show_ym['month']
# 表示対象年月の初日・末日を取得
first_date = Date.new(show_year, show_month, 1)
last_date = Date.new(show_year, show_month, -1)

# 出力
puts("#{show_month}月#{show_year}".center(20))
%w[日 月 火 水 木 金 土].each { |day| printf('%2s'.%(day)) }
puts
# 1日の表示開始位置(曜日)まで空白埋め
first_date.wday.times.each { printf(format('%3s', '')) }
(Date.new(show_year, show_month, 1)..Date.new(show_year, show_month, last_date.mday)).each do |date|
  print '%3d' % date.strftime('%e')
  # 土曜日であれば改行
  puts if date.wday % 7 == 6
end
puts
