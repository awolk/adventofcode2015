# typed: strict
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

gain = P.str(' would gain ').map { 1 }
lose = P.str(' would lose ').map { -1 }
points = ((gain | lose) & P.int).map { _1 * _2 }
parser = P.seq(P.word, points, P.str(' happiness units by sitting next to '), P.word, P.str('.'))
          .map {[[_1, _4], _2]}
          .each_line
          .map(&:to_h)

happiness = T.let(parser.parse_all(AOC.get_input(13)), T::Hash[[String, String], Integer])

sig { params(order: T::Array[String]).returns(T::Array[[String, String]]) }
def adjacencies(order)
  pairs = (order + [order.fetch(0)]).each_cons(2)
  pairs + pairs.map(&:reverse) # [A, B] and [B, A] for every pair
end

# Part 1
people = happiness.keys.flatten.uniq
best_happiness = people.permutation.map do |order|
  adjacencies(order).sum(&happiness)
end.max
puts "Part 1: #{best_happiness}"

# Part 2
people << 'you'
best_happiness = people.permutation.map do |order|
  adjacencies(order).sum { happiness.fetch(_1, 0) }
end.max
puts "Part 2: #{best_happiness}"
