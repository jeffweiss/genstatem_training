defmodule Training.TestUtils do
  def get_current_state(pid) do
    {state, _} = get_state_and_data(pid)
    state
  end

  def get_current_data(pid) do
    {_, data} = get_state_and_data(pid)
    data
  end

  def get_state_and_data(pid) do
    :sys.get_state(pid)
  end
end
