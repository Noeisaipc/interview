defmodule Interview do
  @moduledoc """
  This module generates strings based on a string template
  See the string docs here: https://hexdocs.pm/elixir/String.html
  Binary pattern matching docs here: https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1

  "hello world " = Interview.render("{{foo}} {{bar}} {{baz}}", %{foo: "hello", bar: "world"})
  """

  @opening_delimiter "{{"
  @closing_delimiter "}}"
  @key_separator "."

  @typep value_or_nested_map() :: String.t() | %{atom() => value_or_nested_map()}

  @doc """
  Replaces in a template string the placeholders of the form
  `{{foo}}` with the value under the `param` key in the map
  given as the second parameter.

  It accepts nested keys separated by `.`.
  """
  @spec render(String.t(), %{atom() => value_or_nested_map()}) :: String.t()
  def render("", _params), do: ""
  def render(template, params) do
    do_render(template, params, "")
  end

  defp do_render("", _params, acc), do: acc
  defp do_render(@opening_delimiter <> rest, params, acc) do
    {key, rest} = split_at_closing_delimiter(rest)

    # Utilizo `get_in` que funciona con el behaviour `Access` para acceder a
    # estructuras anidadas. En caso de no existir el valor, la función regresa
    # `nil`, y podemos usar `||` para proveer por defecto la cadena vacía.
    replace = get_in(params, key) || ""

    do_render(rest, params, acc <> replace)
  end
  defp do_render(<<c :: binary-size(1), rest :: binary>>, params, acc) do
    do_render(rest, params, acc <> c)
  end


  defp split_at_closing_delimiter(template), do: do_split_at_closing_delimiter(template, "")

  defp do_split_at_closing_delimiter("", acc_key) do
    {parse_key(acc_key), ""}
  end
  defp do_split_at_closing_delimiter(@closing_delimiter <> rest, acc_key) do
    {parse_key(acc_key), rest}
  end
  defp do_split_at_closing_delimiter(<<c :: binary-size(1), rest :: binary>>, acc_key) do
    do_split_at_closing_delimiter(rest, acc_key <> c)
  end


  # Parses key into the `Access` behaviour's nested-key list access.
  defp parse_key(key) do
    key
    |> String.split(@key_separator)
    |> Enum.map(&String.to_atom/1)
  end
end
