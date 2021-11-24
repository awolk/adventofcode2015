# typed: strict
# frozen_string_literal: true

require_relative './aoc'

class Grid
  extend T::Sig
  extend T::Generic

  Elem = type_member

  sig { returns Integer }
  attr_accessor :rows, :cols

  sig { params(array: T::Array[T::Array[Elem]]).void }
  def initialize(array)
    @array = array
    @rows = T.let(@array.length, Integer)
    @cols = T.let(@array.fetch(0).length, Integer)
    raise 'Expected rectangular grid' unless @array.all? { |row| row.length == @cols }
  end

  sig { params(r: Integer, c: Integer).returns(T.nilable(Elem)) }
  def [](r, c)
    @array[r]&.[](c)
  end

  sig { params(r: Integer, c: Integer, val: Elem).returns(Elem) }
  def []=(r, c, val)
    @array.fetch(r)[c] = val
  end

  sig { params(r: Integer, c: Integer).returns(Elem) }
  def fetch(r, c)
    @array.fetch(r).fetch(c)
  end

  sig { params(r: Integer, c: Integer).returns(T::Array[Elem]) }
  def neighbors(r, c)
    ([r - 1, 0].max..[r + 1, @rows - 1].min).flat_map do |nr|
      ([c - 1, 0].max..[c + 1, @cols - 1].min).filter_map do |nc|
        fetch(nr, nc) unless r == nr && c == nc
      end
    end
  end

  sig do
    type_parameters(:T)
    params(
      blk: T.proc.params(_1: Elem, _2: Integer, _3: Integer).returns(T.type_parameter(:T))
    )
      .returns(Grid[T.type_parameter(:T)])
  end
  def map_with_index(&blk)
    Grid.new(@array.each_with_index.map do |row, row_ind|
      row.each_with_index.map do |val, col_ind|
        blk.call(val, row_ind, col_ind)
      end
    end)
  end

  sig { returns(T::Array[Elem]) }
  def items
    @array.flatten(1)
  end

  sig { returns(Grid[Elem]) }
  def clone
    Grid.new(@array.map(&:clone))
  end

  sig { void }
  def print!
    @array.each { |row| puts(row.join) }
  end
end

input = AOC.get_input(18)
input_grid = Grid[T::Boolean].new(input.split("\n").map do |line|
  line.chars.map(&{ '.' => false, '#' => true })
end)

# Part 1
grid = input_grid.clone
100.times do
  grid = grid.map_with_index do |on, r, c|
    neighbors_on = grid.neighbors(r, c).count {_1}
    neighbors_on == 3 || (on && neighbors_on == 2)
  end
end
total_on = grid.items.count { _1 }
puts "Part 1: #{total_on}"

# Part 2
# Turn on the corners
grid = input_grid
[0, grid.rows - 1].each do |r|
  [0, grid.cols - 1].each do |c|
    grid[r, c] = true
  end
end
100.times do
  grid = grid.map_with_index do |on, r, c|
    # Keep the corners on
    next true if [0, grid.rows - 1].include?(r) && [0, grid.cols - 1].include?(c)

    neighbors_on = grid.neighbors(r, c).count {_1}
    neighbors_on == 3 || (on && neighbors_on == 2)
  end
end
total_on = grid.items.count { _1 }
puts "Part 2: #{total_on}"
