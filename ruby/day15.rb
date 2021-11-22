# typed: strict
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

extend T::Sig

class Ingredient < T::Struct
  extend T::Sig
  const :name, String
  const :capacity, Integer
  const :durability, Integer
  const :flavor, Integer
  const :texture, Integer
  const :calories, Integer

  sig { params(line: String).returns(Ingredient) }
  def self.from_line(line)
    P.seq(P.word, ': capacity ', P.int, ', durability ', P.int, ', flavor ',
          P.int, ', texture ', P.int, ', calories ', P.int)
     .map {new(name: _1, capacity: _2, durability: _3, flavor: _4, texture: _5, calories: _6)}
     .parse_all(line)
  end
end

class Cookie < T::Struct
  extend T::Sig
  const :ingredient_counts, T::Hash[Ingredient, Integer]

  sig { returns(Integer) }
  def score
    total_capacity = ingredient_counts.sum {_1.capacity * _2}
    total_durability = ingredient_counts.sum {_1.durability * _2}
    total_flavor = ingredient_counts.sum {_1.flavor * _2}
    total_texture = ingredient_counts.sum {_1.texture * _2}
    return 0 if [total_capacity, total_durability, total_flavor, total_texture].any?(&:negative?)

    total_capacity * total_durability * total_flavor * total_texture
  end

  sig { returns(Integer) }
  def calories
    ingredient_counts.sum {_1.calories * _2}
  end

  sig { params(ingredient: Ingredient, count: Integer).returns(Cookie) }
  def with_ingredient(ingredient, count)
    Cookie.new(ingredient_counts: ingredient_counts.merge(ingredient => count))
  end
end

sig { params(ingredients: T::Array[Ingredient], total: Integer, _blk: T.proc.params(_1: Cookie).void).void }
def each_cookie(ingredients, total, &_blk)
  if ingredients.length == 1
    yield Cookie.new(ingredient_counts: { ingredients.fetch(0) => total })
  else
    first = ingredients.fetch(0)
    rest = T.must(ingredients[1..])
    (0..total).each do |first_ingredient_count|
      each_cookie(rest, total - first_ingredient_count) do |cookie|
        yield cookie.with_ingredient(first, first_ingredient_count)
      end
    end
  end
end

input = AOC.get_input(15)
ingredients = input.split("\n").map { Ingredient.from_line(_1) }
total = 100
all_cookies = T.let(to_enum(:each_cookie, ingredients, total), T::Enumerator[Cookie])

# Part 1
best_score = all_cookies.map(&:score).max
puts "Part 1: #{best_score}"

# Part 2
best_lowcal_score = all_cookies.filter { _1.calories == 500 }.map(&:score).max
puts "Part 2: #{best_lowcal_score}"
