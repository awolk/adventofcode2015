# typed: strict
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

extend T::Sig

class Sue < T::Struct
  extend T::Sig
  const :number, Integer
  const :children, T.nilable(Integer), default: nil
  const :cats, T.nilable(Integer), default: nil
  const :samoyeds, T.nilable(Integer), default: nil
  const :pomeranians, T.nilable(Integer), default: nil
  const :akitas, T.nilable(Integer), default: nil
  const :vizslas, T.nilable(Integer), default: nil
  const :goldfish, T.nilable(Integer), default: nil
  const :trees, T.nilable(Integer), default: nil
  const :cars, T.nilable(Integer), default: nil
  const :perfumes, T.nilable(Integer), default: nil

  sig { params(line: String).returns(Sue) }
  def self.from_line(line)
    prop = P.seq(P.word.map(&:to_sym), ': ', P.int)
    props = prop.delimited(P.str(', ')).map(&:to_h)
    P.seq('Sue ', P.int, ': ', props)
     .map { new(_2.merge(number: _1)) }
     .parse_all(line)
  end

  sig do
    params(
      params: T::Hash[Symbol, Integer],
      minimum_reading_props: T::Array[Symbol],
      maximum_reading_props: T::Array[Symbol]
    ).returns(T::Boolean)
  end
  def match?(params, minimum_reading_props: [], maximum_reading_props: [])
    params.all? do |name, expected|
      known = public_send(name)
      next true if known.nil?

      if minimum_reading_props.include?(name)
        known > expected
      elsif maximum_reading_props.include?(name)
        known < expected
      else
        known == expected
      end
    end
  end
end

reading = {
  children: 3,
  cats: 7,
  samoyeds: 2,
  pomeranians: 3,
  akitas: 0,
  vizslas: 0,
  goldfish: 5,
  trees: 3,
  cars: 2,
  perfumes: 1
}

input = AOC.get_input(16)
sues = input.split("\n").map { Sue.from_line(_1) }

# Part 1
gift_giver = T.must(sues.find {_1.match?(reading)})
puts "Part 1: #{gift_giver.number}"

# Part 2
real_gift_giver = T.must(sues.find do |sue|
  sue.match?(
    reading,
    minimum_reading_props: %i[cats trees],
    maximum_reading_props: %i[pomeranians goldfish]
  )
end)
puts "Part 2: #{real_gift_giver.number}"
