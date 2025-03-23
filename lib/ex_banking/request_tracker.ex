defmodule ExBanking.RequestTracker do
  @moduledoc """
    This module is responsible for tracking the number of requests that are being processed by the system.
    It uses GenServer to keep track of the number of requests that are being processed.
    The module has the following functions:
    - number_of_requests/1: This function is used to get the number of requests that are being processed.
    - track_request/1: This function is responsible for marking a request as pending and scheduling its removal after a timeout.
    The module has the following callbacks:
    - init/1: This callback is used to initialize the GenServer.
    - handle_info/2: This callback is used to handle the :downstream message.
    - handle_cast/2: This callback is used to handle the :upstream message.
    - handle_call/3: This callback is used to handle the :return message.
    The module has the following attributes:
    - @pending_state_timeout: This attribute is used to set the timeout for the :downstream message.
  """
  use GenServer

  @pending_state_timeout 10_000

  # Callbacks
  @impl true
  @spec init(any()) :: {:ok, 0}
  def init(_) do
    {:ok, 0}
  end

  @impl true
  def handle_info(:downstream, state) do
    {:noreply, state - 1}
  end

  @impl true
  def handle_cast(:upstream, state) do
    {:noreply, state + 1}
  end

  @impl true
  def handle_call(:return, _from, state) do
    {:reply, state, state}
  end

  # functions

  @spec number_of_requests(atom() | pid() | {atom(), any()} | {:via, atom(), any()}) :: any()
  def number_of_requests({:ok, pid}) do
    number_of_requests(pid)
  end

  def number_of_requests(pid) do
    GenServer.call(pid, :return)
  end

  @spec track_request(atom() | pid()) :: reference()
  def track_request(pid) do
    GenServer.cast(pid, :upstream)
    Process.send_after(pid, :downstream, @pending_state_timeout)
  end
end
