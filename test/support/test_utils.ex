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

  def eventually(f, retries \\ 0) do
    f.()
  rescue
    err ->
      if retries >= 10 do
        reraise err, __STACKTRACE__
      else
        :timer.sleep(500)
        eventually(f, retries + 1)
      end
  catch
    _exit, _term ->
      :timer.sleep(500)
      eventually(f, retries + 1)
  end
end
