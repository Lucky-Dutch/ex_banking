defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "creates a user" do
    assert ExBanking.create_user("user1") == :ok
    assert ExBanking.create_user("user1") == {:error, :user_already_exists}
  end

  test "deposits money" do
    ExBanking.create_user("user2")
    assert ExBanking.deposit("user2", 100, "USD") == {:ok, 100}
    assert ExBanking.deposit("user2", 50, "USD") == {:ok, 150}
  end

  test "withdraws money" do
    ExBanking.create_user("user3")
    ExBanking.deposit("user3", 100, "USD")
    assert ExBanking.withdraw("user3", 50, "USD") == {:ok, 50}
    assert ExBanking.withdraw("user3", 60, "USD") == {:error, :not_enough_money}
  end

  test "gets balance" do
    ExBanking.create_user("user4")
    ExBanking.deposit("user4", 100, "USD")
    assert ExBanking.get_balance("user4", "USD") == {:ok, 100}
  end

  test "sends money" do
    ExBanking.create_user("user5")
    ExBanking.create_user("user6")
    ExBanking.deposit("user5", 100, "USD")
    assert ExBanking.send("user5", "user6", 50, "USD") == {:ok, 50, 50}
    assert ExBanking.send("user5", "user6", 60, "USD") == {:error, :not_enough_money}
  end

  test "too many withdrawal requests" do
    ExBanking.create_user("user7")
    ExBanking.deposit("user7", 1000, "USD")

    for _ <- 1..10 do
      ExBanking.withdraw("user7", 1, "USD")
    end

    assert ExBanking.withdraw("user7", 1, "USD") == {:error, :too_many_requests_to_user}
  end
end
