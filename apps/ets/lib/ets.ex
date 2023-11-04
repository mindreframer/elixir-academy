defmodule Ets do
  def check do
    # endless function to keep the process running
    endless = fn ->
      receive do
        :a -> 1
      end
    end

    pid = spawn(endless)

    tab_opts = [
      :duplicate_bag,
      :public,
      {:keypos, 2},
      {:read_concurrency, true}
    ]

    table = :ets.new(:table, tab_opts)

    # give ownership away to endless process
    :ets.give_away(table, pid, [])

    :ets.info(table) |> IO.inspect(lavel: "info")

    # basic content
    :ets.insert(table, {"1", [:live_query], :fun1, [1]})
    :ets.insert(table, {"2", [:live_query], :fun2, [2]})
    :ets.insert(table, {"3", [:another], :fun3, [3]})
    :ets.insert(table, {"4", [:another], :fun4, [4]})

    :ets.tab2list(table) |> IO.inspect(label: "tab2list")
    # this matches everything
    :ets.match(table, :"$1") |> IO.inspect(label: "match")

    # we have keys on the 2-nd position, so lookups happen there
    :ets.lookup(table, [:live_query]) |> IO.inspect(label: "lookup")
    # we can get the element from the found row by using lookup_element
    :ets.lookup_element(table, [:live_query], 1) |> IO.inspect(label: "lookup_element - 1")
    :ets.lookup_element(table, [:live_query], 3) |> IO.inspect(label: "lookup_element - 3")

    ### this has to be executed in the Elixir shell, since ets.fun2ms is funky...
    # match_func =
    #   fn {v1, v2, _, _} when v1 == "1" ->
    #     {v1, v2}
    #   end

    # match_spec = :ets.fun2ms(match_func)
    # very basic match, could be done without matchspec
    match_spec = [
      {
        ## HEAD
        {:"$1", :"$2", :_, :_},
        ## GUARD
        [{:==, :"$1", "1"}],
        ## RESULT
        [{{:"$1", :"$2"}}]
      }
    ]

    :ets.select(table, match_spec) |> IO.inspect(label: "match_spec - 1")
    :ets.match_delete(table, {"1", :_, :_, :_}) |> IO.inspect(label: "match_delete")
    :ets.match_delete(table, {"3", :_, :_, :_}) |> IO.inspect(label: "match_delete")
    :ets.tab2list(table) |> IO.inspect(label: "tab2list")
  end
end
