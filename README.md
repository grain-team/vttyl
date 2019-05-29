# Vttyl

> A dead simple vtt parser in Elixir.

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

For more information, see [the documentation][documentation].

[documentation]: https://hexdocs.pm/vttyl
