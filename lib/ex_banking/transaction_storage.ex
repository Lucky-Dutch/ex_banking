defmodule ExBanking.TransactionStorage do
  @moduledoc """
    This module is responsible for storing the transactions that are being processed by the system.
    It uses ETS to store the transactions.
    The module has the following functions:
    - init/0: This function is used to initialize the ETS.
    - get_user_balance_by_currency/2: This function is used to get the balance of a user by currency.
    - deposit_transaction/3: This function is used to deposit an amount to a user.
    - withdraw_transaction/3: This function is used to withdraw an amount from a user.
    - validate_request_limit/1: This function is used to validate the number of requests that are being processed by the system.
    - validate_user_balance/3: This function is used to validate the balance of a user.
    - count_user_operations/1: This function is used to count the number of operations that are being processed by the system.
    The module has the following attributes:
    - @name: This attribute is used to set the name of the ETS.
    - @bit_32_mask: This attribute is used to set the mask for the 32-bit integer.
  """
  @name :transaction_bucket
  @bit_32_mask 4_294_967_296
  defguard is_valid_transaction(amount, currency)
           when is_number(amount) and amount > 0 and is_binary(currency)

  def init() do
    IO.puts("Creating transaction ETS")
    :ets.new(@name, [:set, :public, :named_table])
    {:ok, "ETS Created"}
  end

  def get_user_balance_by_currency(user_name, currency) when is_binary(currency) do
    balance =
      @name
      |> :ets.match_object({:_, user_name, currency, :_})
      |> Enum.reduce(0, fn {_, _, _, amount}, acc -> acc + amount end)

    {:ok, balance}
  end

  def get_user_balance_by_currency(_user_name, _currency), do: {:error, :wrong_arguments}

  def deposit_transaction(user_name, amount, currency)
      when is_valid_transaction(amount, currency) do
    :ets.insert_new(
      @name,
      {:rand.uniform(@bit_32_mask), user_name, currency, format_money(amount)}
    )
  end

  def deposit_transaction(_user_name, _amount, _currency), do: {:error, :wrong_arguments}

  def withdraw_transaction(user_name, amount, currency)
      when is_valid_transaction(amount, currency) do
    :ets.insert_new(
      @name,
      {:rand.uniform(@bit_32_mask), user_name, currency, format_money(-amount)}
    )
  end

  def withdraw_transaction(_user_name, _amount, _currency), do: {:error, :wrong_arguments}

  def validate_request_limit(user_name) do
    case count_user_operations(user_name) do
      count when count < 10 ->
        :ok

      _ ->
        {:error, :too_many_requests_to_user}
    end
  end

  def validate_user_balance(user_name, amount, currency) do
    case get_user_balance_by_currency(user_name, currency) do
      {:ok, balance} when balance >= amount ->
        :ok

      {:error, :wrong_arguments} = wrong_arg ->
        wrong_arg

      _ ->
        {:error, :not_enough_money}
    end
  end

  def count_user_operations(user_name) do
    user_name
    |> ExBanking.UserStorage.get_user_pid()
    |> ExBanking.RequestTracker.number_of_requests()
  end

  defp format_money(amount) when is_float(amount) do
    Float.round(amount, 2)
  end

  defp format_money(amount), do: amount
end
