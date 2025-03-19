defmodule ExBanking.UserStorage do
  @moduledoc false
  @name :user_bucket

  def init() do
    IO.puts("Creating authorization ETS")
    :ets.new(@name, [:set, :public, :named_table])
    {:ok, "ETS Created"}
  end
end
