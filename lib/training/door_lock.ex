defmodule Training.DoorLock do
  use GenStateMachine, callback_mode: :state_functions

  # This allows our graphviz directed graph to be rendered
  # as an image in the documentation
  import Training.Util.Graphviz

  require Logger

  @fsm_diagram """
  digraph {
    rankdir=LR;
    node [shape=doublecircle]
    locked_0
    node [shape=circle]
    locked_1
    locked_2
    locked_3
    unlocked

    unlocked -> locked_0 [label="re-lock timeout"]
    locked_0 -> locked_1 [label="correct input"]
    locked_0 -> locked_0 [label="incorrect input"]
    locked_1 -> locked_2 [label="correct input"]
    locked_1 -> locked_0 [label="incorrect input"]
    locked_1 -> locked_0 [label="input timeout"]
    locked_2 -> locked_3 [label="correct input"]
    locked_2 -> locked_0 [label="incorrect input"]
    locked_2 -> locked_0 [label="input timeout"]
    locked_3 -> unlocked [label="correct input"]
    locked_3 -> locked_0 [label="incorrect input"]
    locked_3 -> locked_0 [label="input timeout"]
  }
  """

  @fsm_diagram_generic """
  digraph {
    rankdir=LR;
    node [shape=doublecircle]
    locked [label = "locked\n{current_correct_sequence,\nfull_correct_sequence}"]
    node [shape=circle]
    unlocked

    unlocked -> locked [label="re-lock timeout"]
    locked -> locked [label="incorrect\ncurrent_correct_sequence = []"]
    locked -> locked [label="input timeout\ncurrent_correct_sequence = []"]
    locked -> locked [label="correct\ncurrent_correct_sequence ++ input"]
    locked -> unlocked [label="current_correct_sequence == full_correct_sequence"]
  }
  """

  @moduledoc """
  Represents a door lock with an automated re-lock timeout as a state machine.
  This door lock also has a separate timeout that requires a user to input the
  correct code (start-to-finish) in a certain amount of time or else it reverts
  to the initial locked state, clearing any in-progress input.

  As a diagram, the state machine for a 4-digit code is
  #{image(@fsm_diagram, "jpeg")}

  More generically, if we add and track transient input data inside each state,
  we have a state machine diagram that looks more like
  #{image(@fsm_diagram_generic, "jpeg")}
  """

  @relock_timeout 5_000
  @finish_timout 2_000

  @doc """
  Start a door lock with the specified correct code sequence

  Ignores any arguments passed in
  """
  def start_link(secret_code) do
    GenStateMachine.start_link(__MODULE__, [secret_code])
  end

  @doc """
  Initializes a door_lock into the `:locked` state with a people-counter of `0`
  """
  @spec init(any()) :: :gen_statem.init_result(GenStateMachine.state())
  def init([secret_code]) do
    # TODO set starting state and data
    {:ok, :todo, %{current_code: [], secret_code: []}}
  end

  @doc """
  Called while in the `:unlocked` state
  """
  @spec unlocked(
          GenStateMachine.event_type(),
          GenStateMachine.event_content(),
          GenStateMachine.data()
        ) :: :gen_statem.event_handler_result(GenStateMachine.state())
  def unlocked(:state_timeout, :lock, data) do
    # TODO lock when the timeout occurs
  end

  def unlocked({:timeout, :finish}, :reset, data) do
    Logger.error("You should cancel the finish timer")
    {:next_state, :locked, %{data | current_code: []}}
  end

  def unlocked(_, _, _) do
    :keep_state_and_data
  end

  @doc """
  Called while in the `:locked` state
  """
  @spec locked(
          GenStateMachine.event_type(),
          GenStateMachine.event_content(),
          GenStateMachine.data()
        ) :: :gen_statem.event_handler_result(GenStateMachine.state())
  def locked(:cast, {:input, digit}, data) do
    # TODO add necessary input processing and state transition handling
  end

  def locked({:timeout, :finish}, :reset, data) do
    {:keep_state, %{data | current_code: []}}
  end

  def locked(_, _, _) do
    :keep_state_and_data
  end
end
