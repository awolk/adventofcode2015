# typed: true
# frozen_string_literal: true

require_relative './aoc'
require_relative './parser'

module Day7Alt
  Input = T.type_alias { T.any(Integer, String) }

  And = Struct.new(:l, :r)
  Or = Struct.new(:l, :r)
  Rshift = Struct.new(:i, :a)
  Lshift = Struct.new(:i, :a)
  Not = Struct.new(:i)

  Expr = T.type_alias do
    T.any(
      Input,
      And,
      Or,
      Lshift,
      Rshift,
      Not
    )
  end

  input_parser = P.int | P.regexp(/[a-z]+/)
  expr_parser =
    P.seq(input_parser, P.str(' AND '), input_parser).map { And.new(_1, _3) } |
    P.seq(input_parser, P.str(' OR '), input_parser).map { Or.new(_1, _3) } |
    P.seq(input_parser, P.str(' LSHIFT '), P.int).map { Lshift.new(_1, _3) } |
    P.seq(input_parser, P.str(' RSHIFT '), P.int).map { Rshift.new(_1, _3) } |
    (P.str('NOT ') >> input_parser).map { Not.new(_1) } |
    input_parser
  line_parser =
    P.seq(expr_parser, P.str(' -> '), P.regexp(/[a-z]+/))
     .map { |expr, _, target| [target, expr] }
  program_parser = line_parser.each_line.map(&:to_h)

  wiring = T.let(program_parser.parse_all(AOC.get_input(7)), T::Hash[String, Expr])

  class Circuit
    extend T::Sig

    sig { params(wiring: T::Hash[String, Expr]).void }
    def initialize(wiring)
      @wiring = wiring
      @cached = T.let({}, T::Hash[String, Integer])
    end

    sig { params(target: String).returns(Integer) }
    def get(target)
      if (res = @cached[target])
        return res
      end

      expr = @wiring.fetch(target)
      res =
        case expr
        when Integer
          expr
        when String
          get(expr)
        when And
          eval_input(expr.l) & eval_input(expr.r)
        when Or
          eval_input(expr.l) | eval_input(expr.r)
        when Lshift
          eval_input(expr.i) << expr.a
        when Rshift
          eval_input(expr.i) >> expr.a
        when Not
          ~eval_input(expr.i)
        else
          T.absurd(expr)
        end

      @cached[target] = res
    end

    private

    sig { params(input: Input).returns(Integer) }
    def eval_input(input)
      case input
      when String
        get(input)
      when Integer
        input
      else
        T.absurd(input)
      end
    end
  end

  signal_a = Circuit.new(wiring).get('a')

  puts "Part 1: #{signal_a}"

  new_wiring = wiring.merge('b' => signal_a)
  new_signal_a = Circuit.new(new_wiring).get('a')
  puts "Part 2: #{new_signal_a}"
end
