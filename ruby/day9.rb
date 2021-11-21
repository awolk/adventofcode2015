# typed: strict
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

parser = P.seq(P.word, P.str(' to '), P.word, P.str(' = '), P.int)
          .map {[[_1, _3], _5]}
          .each_line
          .map(&:to_h)
distances = T.let(parser.parse_all(AOC.get_input(9)), T::Hash[[String, String], Integer])

locations = distances.keys.flatten.uniq

# for every route A -> B, save the same distance for B -> A
distances.merge!(distances.transform_keys(&:reverse))

possible_dists = locations.permutation.map do |path|
  path.each_cons(2).sum(&distances)
end

puts "Part 1: #{possible_dists.min}"
puts "Part 2: #{possible_dists.max}"
