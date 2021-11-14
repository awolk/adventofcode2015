# typed: strict
# frozen_string_literal: true

require 'set'
require_relative './aoc'

extend T::Sig

Coord = T.type_alias { [Integer, Integer] }

class InstructionType < T::Enum
  enums do
    TurnOn = new('turn on')
    TurnOff = new('turn off')
    Toggle = new('toggle')
  end
end

class Instruction < T::Struct
  extend T::Sig
  const :type, InstructionType
  const :from, Coord
  const :to, Coord

  sig { params(line: String).returns(Instruction) }
  def self.parse(line)
    match = /\A([a-z ]+) (\d+),(\d+) through (\d+),(\d+)\z/.match(line)

    new(
      type: InstructionType.deserialize(T.must(match)[1]),
      from: [T.must(match)[2].to_i, T.must(match)[3].to_i],
      to: [T.must(match)[4].to_i, T.must(match)[5].to_i]
    )
  end
end

sig { params(from: Coord, to: Coord, blk: T.proc.params(_1: Coord).void).void }
def each_coord(from, to, &blk)
  (from[0]..to[0]).each do |x|
    (from[1]..to[1]).each do |y|
      blk.call([x, y])
    end
  end
end

sig { params(instrs: T::Array[Instruction], blk: T.proc.params(_1: InstructionType, _2: Coord).void).void }
def handle_instructions(instrs, &blk)
  instrs.each do |instr|
    each_coord(instr.from, instr.to) do |coord|
      blk.call(instr.type, coord)
    end
  end
end

instructions = AOC.get_input(6).split("\n").map {Instruction.parse(_1)}

# Part 1
on = T.let(Set.new, T::Set[Coord])

handle_instructions(instructions) do |type, coord|
  case type
  when InstructionType::TurnOn
    on.add(coord)
  when InstructionType::TurnOff
    on.delete(coord)
  when InstructionType::Toggle
    on.delete?(coord) || on.add(coord)
  else
    T.absurd(type)
  end
end

puts "Part 1: #{on.length} lights"

# Part 2
brightness = T.let(Hash.new { |h, k| h[k] = 0 }, T::Hash[Coord, Integer])

handle_instructions(instructions) do |type, coord|
  case type
  when InstructionType::TurnOn
    brightness[coord] = T.must(brightness[coord]) + 1
  when InstructionType::TurnOff
    b = T.must(brightness[coord])
    brightness[coord] = b - 1 if b.positive?
  when InstructionType::Toggle
    brightness[coord] = T.must(brightness[coord]) + 2
  else
    T.absurd(type)
  end
end

total_brightness = brightness.values.sum
puts "Part 2: #{total_brightness} lights"
