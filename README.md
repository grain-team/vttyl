# Vttyl

> A dead simple vtt parser in Elixir.

[![CircleCI](https://circleci.com/gh/grain-team/vttyl.svg?style=svg)](https://circleci.com/gh/grain-team/vttyl) [![Hex version badge](https://img.shields.io/hexpm/v/vttyl.svg)](https://hex.pm/packages/vttyl)

## Installation

To install Vttyl, add it to your `mix.exs` file.

```elixir
def deps do
  [
    {:vttyl, "~> 0.3.0"}
  ]
end
```

Then, run `$ mix deps.get`.

## Usage

### Decoding

Vttyl has two basic ways to use it.

#### String Parsing

```elixir
iex> vtt = """
           WEBVTT

           1
           00:00:15.450 --> 00:00:17.609
           Hello world!
           """
...> Vttyl.parse(vtt) |> Enum.into([])
[%Vttyl.Part{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: nil}]
```

#### Stream Parsing

```elixir
iex> "same_text.vtt" |> File.stream!([], 2048) |> Vttyl.parse_stream() |> Enum.into([])
[%Vttyl.Part{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: nil}]
```

#### Simple Voice Spans

(Closing voice spans are currently not supported)

```elixir
iex> vtt = """
           WEBVTT

           1
           00:00:15.450 --> 00:00:17.609
           <v Andy>Hello world!
           """
...> Vttyl.parse(vtt) |> Enum.into([])
[%Vttyl.Part{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: "Andy"}]
```


### Encoding

Vttyl also supports encoding parts.

```elixir
iex> parts = [%Vttyl.Part{end: 17609, part: 1, start: 15450, text: "Hello world!"}]
...> Vttyle.encode(parts)
"""
WEBVTT
1
00:00:15.450 --> 00:00:17.609
Hello world!
"""
```

```elixir
iex> parts = [%Vttyl.Part{end: 17609, part: 1, start: 15450, text: "Hello world!", voice: "Andy"}]
...> Vttyle.encode(parts)
"""
WEBVTT
1
00:00:15.450 --> 00:00:17.609
<v Andy>Hello world!
"""
```

## License

Vttyl is Copyright © 2019 Grain Intelligence, Inc. It is free software, and may be
redistributed under the terms specified in the [LICENSE](/LICENSE) file.

## About Grain

Vttyl is maintained and funded by [Grain Intelligence, Inc][grain_home].
The names and logos for Grain are trademarks of Grain Intelligence, Inc.


For more information, see [the documentation][documentation].

[documentation]: https://hexdocs.pm/vttyl
[grain_home]: https://grain.co
