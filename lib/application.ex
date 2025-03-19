defmodule ExBanking.Application do
  use Application
  def start(_type, _args) do
    ExBanking.UserStorage.init()
    ExBanking.TransactionStorage.init()

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
