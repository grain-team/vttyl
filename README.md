# Vttyl

> A dead simple vtt parser in Elixir.

[![CircleCI](https://circleci.com/gh/grain-team/vttyl.svg?style=svg)](https://circleci.com/gh/grain-team/vttyl) [![Hex version badge](https://img.shields.io/hexpm/v/vttyl.svg)](https://hex.pm/packages/vttyl)

## Installation

To install Vttyl, add it to your `mix.exs` file.

```elixir
def deps do
  [
    {:vttyl, "~> 0.1.0"}
  ]
end
```

Then, run `$ mix deps.get`.

## Usage

Vttyl has two basic ways to use it.

### String Parsing

```elixir
iex> vtt = """
           WEBVTT

           1
           00:00:15.450 --> 00:00:17.609
           Hello world!
           """
...> Vttyl.parse(vtt)
[%Vttyl.Part{end: ~T[00:00:17.609], part: 1, start: ~T[00:00:15.450], text: "Hello world!"}]
```

### Stream Parsing

```elixir
iex> "same_text.vtt" |> File.stream!([], 2048) |> Vttyl.parse_stream() |> Enum.into([])
[%Vttyl.Part{end: ~T[00:00:17.609], part: 1, start: ~T[00:00:15.450], text: "Hello world!"}]
```

## License

Vttyl is Copyright © 2019 Grain Intelligence, Inc. It is free software, and may be
redistributed under the terms specified in the [LICENSE](/LICENSE) file.

## About Grain

Vttyl is maintained and funded by [Grain Intelligence, Inc](grain_home).
The names and logos for Grain are trademarks of Grain Intelligence, Inc.


For more information, see [the documentation][documentation].

[documentation]: https://hexdocs.pm/vttyl
[grain_home]: https://grain.co
