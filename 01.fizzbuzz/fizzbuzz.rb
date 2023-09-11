#!/usr/bin/env ruby

# ループ回数を設定
Roop_amount = 20
#1からカウント
1.upto(Roop_amount).each do |count|
  output = ""
  if count%3==0
    output += "Fizz"
  end
  if count%5==0
    output += "Buzz"
  end
  # ここまでの処理でFizzかBuzzに該当しているか
  if output.empty?
    puts count
  else puts output
  end
end
