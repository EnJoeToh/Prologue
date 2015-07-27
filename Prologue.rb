#! ruby -EUTF-8
# encoding: utf-8

#数字 -> 漢数字変換
def n_to_k num
	kanji = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
	tmp = []
	num.to_s.split("").each do |i|
		tmp << kanji[i.to_i]
	end
	tmp.join
end

#文字カウント
def stat arr
	tmp = Hash.new(0)
	arr.each do |char|
		tmp[char] += 1
	end
	tmp.sort_by {|k, v| -v}
end

# 文字種
hiragana_chars = ("ぁ".."ゖ").to_a + ("゛".."ゟ").to_a
katakana_chars = ("ァ".."ヺ").to_a + ("・".."ヿ").to_a

dir = "./data/Kanji/"

fns = [
 "Thousand_Character_Classic.dat",
 "Regular_Current.dat",
 "Regular_Traditional.dat",
 "Name_Current.dat",
 "Name_Traditional.dat"
]

Kanji = Hash.new

fns.each do |fn|
	path = dir + fn
	name = fn.sub(".dat", "").split("_").map{|i| i[0]}.join.to_sym
	Kanji[name] = File.read(path).chomp.split("")
end

#本文生成

body = Hash.new
(1..12).each do |ch_num|
	num = sprintf("%02d", ch_num)
	fn = "./doc/ch_" + num + ".dat"
	body[ch_num] = File.read(fn)
end

# Ch1 置換

body_chars = body[1].gsub(/<invisible>.*<\/invisible>/m, "").gsub(/<Thousand>.*<\/Thousand>/m, "").split("")

hiragana_remains_01 = (hiragana_chars - body_chars).join
body[1].gsub!("<hiragana_remains_01>", hiragana_remains_01)

katakana_remains_01 = (katakana_chars - body_chars).join
body[1].gsub!("<katakana_remains_01>", katakana_remains_01)

body[1].gsub!("<invisible>", "").gsub!("</invisible>", "")
body[1].gsub!("<Thousand>", "").gsub!("</Thousand>", "")

RC_num = n_to_k((body_chars & Kanji[:RC]).size)
NC_num = n_to_k((body_chars & Kanji[:NC]).size)
TCC_num = n_to_k((body_chars & Kanji[:TCC]).size)

body[1].gsub!("<RC_num>", RC_num)
body[1].gsub!("<NC_num>", NC_num)
body[1].gsub!("<TCC_num>", TCC_num)

body_chars_kana = body_chars.select{|c| hiragana_chars.include?(c)}
body_chars_RC = body_chars.select{|c| Kanji[:RC].include?(c)}

most_letter, most_letter_num = 
  stat(body_chars_kana)[0][0], n_to_k(stat(body_chars_kana)[0][1])
most_kanji, most_kanji_num = 
  stat(body_chars_RC)[0][0], n_to_k(stat(body_chars_RC)[0][1])

body[1].gsub!("<most_letter>", most_letter)
body[1].gsub!("<most_letter_num>", most_letter_num)
body[1].gsub!("<most_kanji>", most_kanji)
body[1].gsub!("<most_kanji_num>", most_kanji_num)

kigou = ["\"", "”", " ", "　", "(", ")", "（", "）", ",", ".", "、", "。", "〇", "「", "」", "『", "』", "\n", "{", "}", "-", "'", "#", "+", "β", "―", "﻿"]

remains = body_chars - hiragana_chars - katakana_chars - Kanji[:RC] - Kanji[:RT] - Kanji[:NC] - Kanji[:NT] - Kanji[:TCC] - ("A".."z").to_a - ("Ａ".."ｚ").to_a - ("0".."9").to_a - ("０".."９").to_a - kigou

new_chars = remains.uniq.sort.join

body[1].gsub!("<new_chars>", new_chars)

puts body[1]

__END__
body.each do |ch, doc|
	puts doc
	puts "\n"
end