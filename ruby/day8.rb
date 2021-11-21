# typed: strict
# frozen_string_literal: true

require_relative './aoc'

extend T::Sig

sig { params(s: String).returns(Integer) }
def decoded_length(s)
  s.gsub(/\\\\|\\"|\\x[0-9a-f]{2}/, '-').length - 2
end

strings = AOC.get_input(8).split("\n")
original_chars = strings.sum(&:length)

evaluated_chars = strings.map { decoded_length(_1) }.sum
puts "Part 1: #{original_chars - evaluated_chars}"

encoded_chars = strings.map(&:inspect).sum(&:length)
puts "Part 2: #{encoded_chars - original_chars}"
