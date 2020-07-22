defmodule Training.Switch do
  use GenStateMachine, callback_mode: :state_functions

  # This allows our graphviz directed graph to be rendered
  # as an image in the documentation
  import Training.Util.Graphviz

  @fsm_diagram """
  digraph {
    rankdir=LR
    node [shape=doublecircle]
    off
    node [shape=circle]
    on

    off -> on [label="flip"]
    on -> off [label="flip"]
  }
  """

  @moduledoc """
  Represents a switch, like a lightswitch, as a state machine

  As a diagram, the state machine is
  #{image(@fsm_diagram, "jpeg")}
  """

  @doc """
  Start a switch

  Ignores any arguments passed in
  """
  def start_link(args \\ []) do
    GenStateMachine.start_link(__MODULE__, args)
  end

  @doc """
  Initializes a switch into the `:off` state
  """
  @spec init(any()) :: :gen_statem.init_result(GenStateMachine.state())
  def init(_) do
    {:ok, :off, nil}
  end

  @doc """
  Called while in the `:on` state
  """
  @spec on(
          GenStateMachine.event_type(),
          GenStateMachine.event_content(),
          GenStateMachine.data()
        ) :: :gen_statem.event_handler_result(GenStateMachine.state())
  def on(:cast, :flip, data) do
    {:next_state, :off, data}
  end

  def on(_, _, _) do
    :keep_state_and_data
  end

  @doc """
  Called while in the `:off` state
  """
  @spec off(
          GenStateMachine.event_type(),
          GenStateMachine.event_content(),
          GenStateMachine.data()
        ) :: :gen_statem.event_handler_result(GenStateMachine.state())
  def off(:cast, :flip, data) do
    {:next_state, :on, data}
  end

  def off(_, _, _) do
    :keep_state_and_data
  end
end
