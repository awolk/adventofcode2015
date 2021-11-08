# typed: strict
# frozen_string_literal: true

require_relative './aoc'

extend T::Sig

words = AOC.get_input(5).split("\n")

# Part 1
VOWELS = T.let('aeiou', String)
BAD_PAIRS = T.let(/(ab|cd|pq|xy)/, Regexp)
DOUBLES = T.let(/([a-z])\1/, Regexp)

sig { params(word: String).returns(T::Boolean) }
def nice?(word)
  (word.count(VOWELS) >= 3) &&
    !word.match?(BAD_PAIRS) &&
    word.match?(DOUBLES)
end

nice_count = words.count {nice?(_1)}
puts "Part 1: #{nice_count}"

# Part 2
REPEATED_PAIR = T.let(/([a-z]{2}).*\1/, Regexp)
SANDWICH = T.let(/([a-z])[a-z]\1/, Regexp)

sig { params(word: String).returns(T::Boolean) }
def nice2?(word)
  word.match?(REPEATED_PAIR) && word.match?(SANDWICH)
end

nice2_count = words.count {nice2?(_1)}
puts "Part 2: #{nice2_count}"
