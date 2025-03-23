defmodule ExBanking.UserStorage do
  @moduledoc """
    This module is responsible for storing the users that are being processed by the system.
    It uses ETS to store the users.
    The module has the following functions:
    - init/0: This function is used to initialize the ETS.
    - create_user/1: This function is used to create a user.
    - verify_user/1: This function is used to verify a user.
    - get_user_pid/1: This function is used to get the PID of a user.
    - get_all_users/0: This function is used to get all the users.
  """
  @name :user_bucket

  def init() do
    IO.puts("Creating authorization ETS")
    :ets.new(@name, [:set, :public, :named_table])
    {:ok, "ETS Created"}
  end

  def create_user(user_name) when is_binary(user_name) do
    case :ets.lookup(@name, user_name) do
      [] ->
        {:ok, pid_2} = GenServer.start_link(ExBanking.RequestTracker, user_name)
        :ets.insert(@name, {user_name, pid_2})
        :ok

      _ ->
        {:error, :user_already_exists}
    end
  end

  def create_user(_), do: {:error, :wrong_arguments}

  def verify_user(user_name) do
    case :ets.lookup(@name, user_name) do
      [] ->
        {:error, :user_does_not_exist}

      _ ->
        {:ok, user_name}
    end
  end

  def get_user_pid(user_name) do
    case :ets.lookup(@name, user_name) do
      [{_, pid}] ->
        {:ok, pid}

      _ ->
        {:error, :user_does_not_exist}
    end
  end

  def get_all_users() do
    :ets.tab2list(@name)
  end
end
