defmodule EtsTest do
  use ExUnit.Case
  doctest Ets

  test "greets the world" do
    assert Ets.hello() == :world
  end
end
