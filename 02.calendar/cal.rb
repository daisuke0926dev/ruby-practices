#!/usr/bin/env ruby
require 'optparse'
require "date"

# ----------------------------------------------
# コマンドラインオプションで年月を受け取ります。(省略可)
# 返値：ハッシュ["year":yyyy, "month":mm(0埋め無し)]
# ----------------------------------------------
def get_show_ym

  ret_date = {"year"=>Time.now.year.to_i ,"month"=>Time.now.month.to_i}
  opt = OptionParser.new
  # 年の指定
  opt.on('-y', '--year [ITEM]', 'select year') do |param_year|
    if param_year != nil
      ret_date["year"] = param_year.to_i
    end
    # パラメータチェック
    if ret_date["year"] < 1970 || ret_date["year"] > 2100
      puts("年の指定に誤りがあります。")
      exit
    end
  end
  
  # 月の指定
  opt.on('-m', '--month [ITEM]', 'select month') do |param_month|
    if param_month != nil
      ret_date["month"] = param_month.to_i
    end
    # パラメータチェック
    if ret_date["month"] < 1 || ret_date["month"] > 12
      puts("月の指定に誤りがあります。")
      exit
    end
  end
  opt.parse(ARGV)

  # 返値
  ret_date
end

#--------------------------------
# 引数で指定された日付の曜日を返します。
# 返値:0-6(日-土)
#--------------------------------
def get_wday(year,month,day)
  date = Date.new(year,month,day)
  date.wday
end

#--------------------------------
# 指定された年月の末日を返します。
#--------------------------------
def get_last_date(year, month)
  last_date = Date.new(year,month,-1)
end

#--------------------------------
# メイン処理
#--------------------------------
# 表示対象年月を取得
show_ym = get_show_ym
show_year = show_ym["year"]
show_month =show_ym["month"] 
# 表示対象年月の末日を取得
last_date = get_last_date(show_year,show_month)
# 1日の曜日を取得
wday_of_the_first_day = get_wday(show_year,show_month,1)

# 出力
puts("#{show_month}月#{show_year}".center(20))
["日","月","火","水","木","金","土"].each{|day| printf("%2s".%(day))}
puts()
# 1日の表示開始位置(曜日)まで空白埋め
wday_of_the_first_day.times.each{printf("%3s".%(""))}
(Date.new(show_year, show_month, 1)..Date.new(show_year, show_month, last_date.mday)).each do |date|
  print "%3d" % date.strftime("%e")
  if date.wday%7 == 6
    # 土曜日であれば改行
    puts()
  end
end
puts()
