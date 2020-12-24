defmodule Vttyl do
  @moduledoc """
  Encoding and decoding VTT files
  """

  alias Vttyl.{Encode, Decode, Part}

  @doc """
  Parse a string.

  This drops badly formatted vtt files.

  This returns a stream so you decide how to handle it!
  """
  @doc since: "0.1.0"
  @spec parse(String.t()) :: Enumerable.t()
  def parse(content) do
    content
    |> String.splitter("\n")
    |> Decode.parse()
  end

  @doc """
  Parse a stream of utf8 encoded characters.

  This returns a stream so you decide how to handle it!
  """
  @doc since: "0.1.0"
  @spec parse_stream(Enumerable.t()) :: Enumerable.t()
  def parse_stream(content) do
    content
    |> Stream.transform("", &next_line/2)
    |> Decode.parse()
  end

  defp next_line(chunk, acc) do
    case String.split(<<acc::binary, chunk::binary>>, "\n") do
      [] ->
        {[], ""}

      lines ->
        {acc, lines} = List.pop_at(lines, -1)
        {lines, acc}
    end
  end

  @doc """
  Encodes a list of parts into a vtt file.
  """
  @doc since: "0.4.0"
  @spec encode_vtt([Part.t()]) :: String.t()
  def encode_vtt(parts) do
    Enum.join(["WEBVTT" | Enum.map(parts, &Encode.encode_part(&1, :vtt))], "\n\n") <> "\n"
  end

  @doc """
  Encodes a list of parts into a srt file.
  """
  @doc since: "0.4.0"
  @spec encode_srt([Part.t()]) :: String.t()
  def encode_srt(parts) do
    Enum.join([Enum.map(parts, &Encode.encode_part(&1, :srt))], "\n\n") <> "\n"
  end

  @doc """
  Encodes a list of parts into a vtt file.

  This is currently deprecated use encode_vtt/1 or encode_srt/1 instead
  """
  @doc since: "0.3.0"
  @spec encode([Part.t()]) :: String.t()
  def encode(parts) do
    Enum.join(["WEBVTT" | Enum.map(parts, &Encode.encode_part(&1, :vtt))], "\n\n") <> "\n"
  end
end
