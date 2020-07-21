defmodule Training.TurnstileTest do
  use ExUnit.Case

  import Training.TestUtils

  alias Training.Turnstile

  test "turnstile starts in a locked state" do
    turnstile = start_supervised!(Turnstile)

    assert :locked == get_current_state(turnstile)
  end

  test "adding coin unlocks locked turnstile" do
    turnstile = start_supervised!(Turnstile)
    GenStateMachine.cast(turnstile, :coin)

    assert :unlocked == get_current_state(turnstile)
  end

  test "pushing locked turnstile is still locked" do
    turnstile = start_supervised!(Turnstile)
    GenStateMachine.cast(turnstile, :push)

    assert :locked == get_current_state(turnstile)
  end

  test "pushing unlocked turnstile locks it" do
    turnstile = start_supervised!(Turnstile)
    GenStateMachine.cast(turnstile, :coin)
    assert :unlocked == get_current_state(turnstile)

    GenStateMachine.cast(turnstile, :push)

    assert :locked == get_current_state(turnstile)
  end

  test "adding coin to unlocked turnstile is still unlocked" do
    turnstile = start_supervised!(Turnstile)
    GenStateMachine.cast(turnstile, :coin)
    assert :unlocked == get_current_state(turnstile)

    GenStateMachine.cast(turnstile, :coin)
    assert :unlocked == get_current_state(turnstile)
  end

  test "turnstile keeps track of people that have gone through it" do
    turnstile = start_supervised!(Turnstile)
    assert 0 == get_current_data(turnstile)

    GenStateMachine.cast(turnstile, :coin)
    GenStateMachine.cast(turnstile, :push)
    assert 1 == get_current_data(turnstile)

    GenStateMachine.cast(turnstile, :coin)
    GenStateMachine.cast(turnstile, :push)
    assert 2 == get_current_data(turnstile)
  end
end
