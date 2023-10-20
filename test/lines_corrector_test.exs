defmodule VendoredSourcerorTest.LinesCorrectorTest do
  use ExUnit.Case, async: true
  doctest VendoredSourceror.LinesCorrector

  import VendoredSourceror, only: [parse_string!: 1]
  import VendoredSourceror.LinesCorrector, only: [correct: 1]

  describe "correct/1" do
    test "keeps previous line number if missing" do
      corrected = correct(parse_string!("foo; bar"))
      assert {:__block__, block, [{:foo, foo, _}, {:bar, bar, _}]} = corrected

      assert block[:line] == 1
      assert foo[:line] == 1
      assert bar[:line] == 1

      assert VendoredSourceror.to_string(corrected) ==
               ~S"""
               foo
               bar
               """
               |> String.trim()
    end

    test "increments line number if it's too low" do
      assert {:__block__, block_meta, [foo, bar]} = parse_string!("foo; bar")

      bar = VendoredSourceror.correct_lines(bar, -2)

      corrected = correct({:__block__, block_meta, [foo, bar]})

      assert {:__block__, _, [{:foo, foo_meta, _}, {:bar, bar_meta, _}]} = corrected

      # kept as it
      assert foo_meta[:line] == 1
      # set to the same as the previous one
      assert bar_meta[:line] == 1

      assert VendoredSourceror.to_string(corrected) ==
               ~S"""
               foo
               bar
               """
               |> String.trim()
    end

    test "increments end lines" do
      assert {:foo, foo_meta, [[{do_kw, bar}]]} = parse_string!("foo do bar end")

      bar =
        VendoredSourceror.append_comments(bar, [
          %{line: 1, previous_eol_count: 1, next_eol_count: 1, text: "# bar comment"}
        ])

      corrected = correct({:foo, foo_meta, [[{do_kw, bar}]]})

      assert {:foo, foo_meta, [[{_, {:bar, bar_meta, _}}]]} = corrected

      assert foo_meta[:line] == 1
      assert bar_meta[:line] == 3
      assert foo_meta[:end][:line] == 3

      assert VendoredSourceror.to_string(corrected) ==
               ~S"""
               foo do
                 # bar comment
                 bar
               end
               """
               |> String.trim()
    end
  end
end
