defmodule ExBanking.TransactionStorage do
  @name :transaction_bucket

  def init() do
    IO.puts("Creating transaction ETS")
    :ets.new(@name, [:set, :public, :named_table])
    {:ok, "ETS Created"}
  end
end
