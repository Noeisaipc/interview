defmodule InterviewTest do
  use ExUnit.Case
  doctest Interview

  test "nothing" do
    assert Interview.render("",%{}) == ""
  end

  test "with key" do
    assert Interview.render("some {{key}}", %{key: "foo"}) == "some foo"
  end
  test "duplicate keys" do
    assert Interview. render("{{key}} and {{key}}", %{key: "foo"}) == "foo and foo"
  end

  test "blank for missing key" do
    assert Interview.render("{{no_key}}", %{}) == ""
  end

  test "full template text" do
    assert Interview.render("field1: ({foo}), {{bar}), ({baz)}", %{foo: "{{foo}}", bar: "this is bar"}) == "field1: {{foo}}, this is bar,"
  end
end
