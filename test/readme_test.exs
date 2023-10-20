defmodule VendoredSourcerorTest.ReadmeTest do
  use ExUnit.Case, async: true

  alias VendoredSourcerorTest.Support.Parser
  require Parser

  @project VendoredSourceror.MixProject.project()

  readme_path = Parser.resource("README.md")
  readme = Parser.code_blocks(readme_path)

  @readme readme

  test "the version numbers match" do
    [_, version] = Regex.run(~r/\{:sourceror, "~> (.*)"\}/, @readme |> hd |> elem(0))
    assert @project[:version] =~ version
  end

  env = __ENV__

  readme
  |> tl
  |> Enum.each(
    &Code.eval_string(
      elem(&1, 0),
      [],
      %{env | file: readme_path, line: elem(&1, 1)}
    )
  )

  @external_resource readme_path
end
