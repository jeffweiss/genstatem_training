defmodule Training.DoorLockTest do
  use ExUnit.Case

  import Training.TestUtils

  alias Training.DoorLock

  test "door lock starts in a locked state" do
    lock = start_supervised!({DoorLock, 1234})

    assert :locked == get_current_state(lock)
  end

  test "incorrect inputs while locked are not tracked" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 0})

    assert :locked = get_current_state(lock)
    assert %{current_code: []} = get_current_data(lock)
  end

  test "next correct number in sequence is tracked" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 1})

    assert :locked = get_current_state(lock)
    assert %{current_code: [1]} = get_current_data(lock)

    GenStateMachine.cast(lock, {:input, 2})

    assert :locked = get_current_state(lock)
    assert %{current_code: [1, 2]} = get_current_data(lock)
  end

  test "current sequence resets with incorrect input" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 1})
    GenStateMachine.cast(lock, {:input, 1})

    assert :locked = get_current_state(lock)
    assert %{current_code: []} = get_current_data(lock)
  end

  test "correct sequence opens lock" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 1})
    GenStateMachine.cast(lock, {:input, 2})
    GenStateMachine.cast(lock, {:input, 3})
    GenStateMachine.cast(lock, {:input, 4})

    assert :unlocked = get_current_state(lock)
  end

  test "correct sequence after incorrect sequence opens lock" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 1})
    GenStateMachine.cast(lock, {:input, 0})
    GenStateMachine.cast(lock, {:input, 1})
    GenStateMachine.cast(lock, {:input, 2})
    GenStateMachine.cast(lock, {:input, 3})
    GenStateMachine.cast(lock, {:input, 4})

    assert :unlocked = get_current_state(lock)
  end

  test "automatically re-locks after timeout" do
    lock = start_supervised!({DoorLock, 1234})
    GenStateMachine.cast(lock, {:input, 1})
    GenStateMachine.cast(lock, {:input, 2})
    GenStateMachine.cast(lock, {:input, 3})
    GenStateMachine.cast(lock, {:input, 4})

    assert :unlocked = get_current_state(lock)

    eventually(fn ->
      assert :locked = get_current_state(lock)
    end)
  end

  test "handles arbitrarily long secret codes" do
    random_number = :random.uniform(100_000)

    lock = start_supervised!({DoorLock, random_number})

    Enum.reduce(Integer.digits(random_number), 0, fn current, acc ->
      GenStateMachine.cast(lock, {:input, current})
      acc
    end)

    assert :unlocked == get_current_state(lock)
  end
end
