#!/usr/bin/env ruby
# frozen_string_literal: true

STRIKE_SCORE = 10
FIRST_FRAME = 1
LAST_FRAME = 10

#---------------------------
# フレーム分割処理
#---------------------------
def split_score_by_frame(scores)
  frame_count = FIRST_FRAME
  # 返却用ハッシュ
  frame_to_scores = {}

  while frame_count < LAST_FRAME
    frame_to_scores[frame_count] = if scores.first == STRIKE_SCORE
                                     [scores.shift]
                                   else
                                     scores.shift(2)
                                   end
    frame_count += 1
  end

  # 最終フレームの処理
  frame_to_scores[LAST_FRAME] = scores

  frame_to_scores
end

#---------------------------
# ボーリング計算処理
#---------------------------
def calc_score(frame_to_scores)
  # 返却用
  frame_to_total = {}
  two_times_strike = false
  is_strike = false
  is_spare = false

  FIRST_FRAME.upto(LAST_FRAME) do |frame_count|
    # 点数群を受け取る
    scores = frame_to_scores[frame_count]
    scores.each_with_index do |score, ball_count|
      # 前フレームへの処理
      frame_to_total[frame_count - 2] += score if two_times_strike && ball_count.zero?
      frame_to_total[frame_count - 1] += score if can_add_previous_frame?(is_strike, is_spare, ball_count)

      # 今フレームへの処理
      frame_to_total[frame_count] = frame_to_total[frame_count].to_i + score
    end

    # フレームごとの後処理
    two_times_strike = is_strike && scores.size == 1
    is_strike = scores.size == 1
    is_spare = scores.size == 2 && frame_to_total[frame_count] == STRIKE_SCORE
  end
  frame_to_total
end

#---------------------------
# 前フレームへ加算するか判断
#---------------------------
def can_add_previous_frame?(is_strike, is_spare, ball_count)
  (is_strike && ball_count < 2) || (is_spare && ball_count < 1)
end

#---------------------------
# メイン処理
#---------------------------
# コマンドライン引数を受け取り、配列に格納
param_score_csv = ARGV[0].split(',')
# 点数を数値に変換
param_score_csv = param_score_csv.map do |val|
  if val == 'X'
    10
  else
    val.to_i
  end
end

# フレームごとに分割
frame_to_scores = split_score_by_frame(param_score_csv)

# ボーリング計算
frame_to_total = calc_score(frame_to_scores)

# 出力
puts(frame_to_total.values.inject(:+))
