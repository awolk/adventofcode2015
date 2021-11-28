# typed: strict
# frozen_string_literal: true

require 'set'
require_relative './aoc'
require_relative './parser'

molecule_parser = P.regexp(/[A-Z][a-z]*/).repeated
replacement_parser = P.seq(P.word, ' => ', molecule_parser).each_line
input_parser = P.seq(replacement_parser, "\n\n", molecule_parser)

input = AOC.get_input(19)
replacements, start = T.let(
  input_parser.parse_all(input),
  [T::Array[[String, T::Array[String]]], T::Array[String]]
)

# Part 1
forward_mapping = replacements.each_with_object({}) do |(a, b), h|
  (h[a] ||= []) << b
end.to_h

molecules = T.let(Set.new, T::Set[T::Array[String]])
start.each_with_index do |val, ind|
  forward_mapping[val]&.each do |replacement|
    molecules << (T.must(start[...ind]) + replacement + T.must(start[(ind + 1)..]))
  end
end

puts "Part 1: #{molecules.length}"

# Part 2
# Simple greedy solution that works on the given input but isn't generic.
# Works backwards from input to e.
current = start.join
steps = 0
replacement_strs = replacements.map { [_1, _2.join] }
while current != 'e'
  replacement_strs.each do |from, to|
    while current.include?(to)
      steps += 1
      current.sub!(to, from)
    end
  end
end
puts "Part 2: #{steps}"
