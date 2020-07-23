# gen_statem Training

This repository is designed to help you learn the ins and outs of `:gen_statem`
and its Elixir wrapper, GenStateMachine. This takes inspiration from Chris Keathley's
[distributed systems training](https://github.com/keathley/distsys_training).

The training is intended to be entirely test-driven. You will need to refer to
the [gen_statem docs](https://erlang.org/doc/design_principles/statem.html) to
complete the exercises.

## Running the tests

The training is broken into specific exercises. You should run only the tests
for that exercise.

Start with the Switch exercise

```
$ mix test test/01_switch_test.exs
```

Then move to the Turnstile exercise

```
$ mix test test/02_turnstile_test.exs
```


## State machine diagrams

If you have installed graphviz, when you generate the documentation with `mix
docs`, the dot-language directed graphs in the modules will be rendered as state
diagrams in the API documentation. This may help you visualize what each
exercise is trying to achieve.

## Areas of gen_statem covered

As illustrated by the
[docs](https://erlang.org/doc/design_principles/statem.html), gen_statem has
considerable functionality. The execises in the tests current address these
aspects:

- [x] pure state transitions
- [x] state transitions + data transitions
- [x] state timeouts
- [x] non-state-dependent timeouts
- [ ] state enter callbacks
- [ ] `handle_event` versions of functions
- [ ] `call`s
