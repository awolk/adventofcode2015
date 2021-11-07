# typed: strict
# frozen_string_literal: true

require_relative './aoc'

input = AOC.get_input(1)

# Part 1
lparen = input.count('(')
rparen = input.count(')')
end_floor = lparen - rparen
puts "Part 1: #{end_floor}"

# Part 2
current_floor = 0
input.each_char.with_index do |char, index|
  current_floor += { '(' => 1, ')' => -1 }.fetch(char)
  if current_floor == -1
    puts "Part 2: #{index + 1}"
    break
  end
end
