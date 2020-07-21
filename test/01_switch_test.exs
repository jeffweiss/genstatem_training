defmodule Training.SwitchTest do
  use ExUnit.Case

  import Training.TestUtils

  alias Training.Switch

  test "switch starts in an off state" do
    switch = start_supervised!(Switch)

    assert :off == get_current_state(switch)
  end

  test "flipping an off switch turns it on" do
    switch = start_supervised!(Switch)
    GenStateMachine.cast(switch, :flip)

    assert :on == get_current_state(switch)
  end

  test "flipping an on switch turns it off" do
    switch = start_supervised!(Switch)
    GenStateMachine.cast(switch, :flip)

    assert :on == get_current_state(switch)
    GenStateMachine.cast(switch, :flip)

    assert :off == get_current_state(switch)
  end
end
