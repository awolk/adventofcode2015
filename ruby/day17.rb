# typed: strict
# frozen_string_literal: true

require_relative './aoc'

input = AOC.get_input(17).split("\n").map(&:to_i)
total = 150

combinations_per_length = (0...input.length).map do |len|
  input.combination(len).count { |comb| comb.sum == total }
end

puts "Part 1: #{combinations_per_length.sum}"
puts "Part 2: #{combinations_per_length.reject(&:zero?).first}"
