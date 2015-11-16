#! ruby -EUTF-8
# encoding: utf-8

require 'pp'

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
alphabet_chars = ("A".."z").to_a + ("ａ".."ｚ").to_a +  ("Ａ".."Ｚ").to_a
number_chars = ("0".."9").to_a + ("０".."９").to_a
kigou_chars = ["\"", "”", " ", "　", "(", ")", "（", "）", ",", ".", "、", "。", "〇", "「", "」", "『", "』", "\n", "{", "}", "-", "'", "#", "+", "β", "―", "﻿", "{", "}", "｛", "｝", "&", "&", ":", "\’", "…", "─", "〔", "〕", "!", "！", "%", "/", "|", "Ⅱ", "↑", "→", "	", "*", "–", "Ⅳ", "Ⓡ", "∅", "“", " ", "↓", "★", "=", "×", "λ", "א", "ⅰ", "ⅱ", "㎐", "Ⅲ", "●", "㎜", "〈", "〉", "【", "〝", "〟", "／", "：", "％", "＝", "，", "［", "］", "＊", "－", "ʀ", "╱"]
roma_nums = ("Ⅰ".."ⅿ").to_a

ex_chars = alphabet_chars + number_chars + kigou_chars + roma_nums


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

#本文読込

body = Hash.new
(1..12).each do |ch_num|
	num = sprintf("%02d", ch_num)
	fn = "./doc3/ch_" + num + ".dat"
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

remains = body_chars - hiragana_chars - katakana_chars - Kanji[:RC] - Kanji[:RT] - Kanji[:NC] - Kanji[:NT] - Kanji[:TCC] - alphabet_chars - number_chars - kigou_chars - roma_nums

new_chars = remains.uniq.sort.join

body[1].gsub!("<new_chars>", new_chars)

#puts body[1]

#Ch10 置換

target = []
(1..8).each do |ch_num|
	target += body[ch_num].split(//)
end

body[10].gsub!("<RCremained_10>", n_to_k((Kanji[:RC] - target).size))

table = stat(target) 

body[10].gsub!("<first_10>", table[0][0])
body[10].gsub!("<second_10>", table[1][0])
body[10].gsub!("<third_10>", table[2][0])
body[10].gsub!("<forth_10>", table[3][0])
body[10].gsub!("<fifth_10>", table[4][0])

body[10].gsub!("<first_num_10>", table[0][1].to_s)
body[10].gsub!("<second_num_10>", table[1][1].to_s)
body[10].gsub!("<third_num_10>", table[2][1].to_s)
body[10].gsub!("<forth_num_10>", table[3][1].to_s)
body[10].gsub!("<fifth_num_10>", table[4][1].to_s)


msg = table[0..99].map do |i|
	a = i[0][0]
	if a == "\n" then a = "\\n" end
	"「" + a + "」"
end
msg = msg.join("、")

body[10].gsub!("<rank100_10>", msg)


(1..8).each do |ch|
	File.write("./tmp/#{ch.to_s}.dat", body[ch].gsub("、", "、\n").gsub("。", "。\n"))
end

bag = []
bag << `mecab ./tmp/1.dat`.split("\n")
bag << `mecab ./tmp/2.dat`.split("\n")
bag << `mecab ./tmp/3.dat`.split("\n")
bag << `mecab ./tmp/4.dat`.split("\n")
bag << `mecab ./tmp/5.dat`.split("\n")
bag << `mecab ./tmp/6.dat`.split("\n")
bag << `mecab ./tmp/7.dat`.split("\n")
bag << `mecab ./tmp/8.dat`.split("\n")

words_bag = []

bag.each do |i|
	i.delete("EOS")
	i.map! do |j|
		j.split("\t")
	end
	i.map! do |j|
		j[1].split(",").unshift(j[0])
	end
	words_bag += i
end

#pp words_bag.uniq.size

words_bag_org = words_bag.map do |i|
	a = i[1], i[-3]
end

#pp words_bag_org.uniq.size

verb_bag = words_bag.select {|mecab| mecab[1] == "動詞"}
adv_bag = words_bag.select {|mecab| mecab[1] == "副詞"}
adj_bag = words_bag.select {|mecab| mecab[1] == "形容詞"}

verb_bag_org = verb_bag.map {|i| a = i[1], i[-3]}
adv_bag_org = adv_bag.map {|i| a = i[1], i[-3]}
adj_bag_org = adj_bag.map {|i| a = i[1], i[-3]}

#p verb_bag_org.uniq.size
#p adv_bag_org.uniq.size
#p adj_bag_org.uniq.size

body[10].gsub!("<verb_num_10>", n_to_k(verb_bag_org.uniq.size))
body[10].gsub!("<adv_num_10>", n_to_k(adv_bag_org.uniq.size))
body[10].gsub!("<adj_num_10>", n_to_k(adj_bag_org.uniq.size))

adj_list = adj_bag_org.map {|i| i[1]}
#puts adj_list.uniq.sort.join("、")

body[10].gsub!("<adj_list>", adj_list.uniq.sort.join("、"))

#ch 2-12 末尾追加

new_letters = Hash.new
new_letters[1] = body[1].split(//) 
old_letters = body[1].split(//) + ex_chars + Kanji[:RC] + Kanji[:RT] + Kanji[:NC] + Kanji[:NT] 
old_letters.uniq!
(2..12).each do |ch_num|
	letters = body[ch_num].split(//)
	new_letters[ch_num] =  letters - old_letters
#p new_letters[ch_num]
	if new_letters[ch_num] then 
		new_letters[ch_num].uniq!
		new_letters[ch_num].sort!		
		old_letters += new_letters[ch_num]
		old_letters.uniq!
	end	
end

(2..12).each do |ch_num|
#	msg = "\n　この回で新たに登場した漢字の数は、#{n_to_k(new_letters[ch_num].size.to_s)}個であった。\n"
	msg = "\n　──この回から新たに取得された漢字は、「#{new_letters[ch_num].join}」の#{n_to_k(new_letters[ch_num].size.to_s)}字である。\n"
#	puts msg


	body[ch_num] += msg
end

#puts body[10]

body.each do |ch, doc|
	puts doc
	puts "\n"
end