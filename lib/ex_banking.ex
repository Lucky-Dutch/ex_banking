defmodule ExBanking do
  @moduledoc """
  This module is the main module of the ExBanking application.
  It is responsible for handling the business logic of the application.
  The module has the following functions:
  - create_user/1: This function is used to create a user.
  - deposit/3: This function is used to deposit money to a user.
  - withdraw/3: This function is used to withdraw money from a user.
  - get_balance/2: This function is used to get the balance of a user.
  - send/4: This function is used to send money from one user to another.
  """

  alias ExBanking.UserStorage
  alias ExBanking.TransactionStorage
  alias ExBanking.RequestTracker

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    UserStorage.create_user(user)
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    with {:ok, pid} <- UserStorage.get_user_pid(user),
         :ok <- TransactionStorage.validate_request_limit(user),
         true <- TransactionStorage.deposit_transaction(user, amount, currency) do
      RequestTracker.track_request(pid)

      TransactionStorage.get_user_balance_by_currency(user, currency)
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with {:ok, pid} <- UserStorage.get_user_pid(user),
         :ok <- TransactionStorage.validate_user_balance(user, amount, currency),
         :ok <- TransactionStorage.validate_request_limit(user),
         true <- TransactionStorage.withdraw_transaction(user, amount, currency) do
      RequestTracker.track_request(pid)

      TransactionStorage.get_user_balance_by_currency(user, currency)
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with {:ok, pid} <- UserStorage.get_user_pid(user),
         :ok <- TransactionStorage.validate_request_limit(user),
         {:ok, balance} <- TransactionStorage.get_user_balance_by_currency(user, currency) do
      RequestTracker.track_request(pid)

      {:ok, balance}
    end
  end

  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    with {:ok, from_user_balance} <- withdraw(from_user, amount, currency),
         {:ok, to_user_balance} <- deposit(to_user, amount, currency) do
      {:ok, from_user_balance, to_user_balance}
    end
  end
end
