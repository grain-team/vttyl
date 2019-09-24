defmodule Vttyl do
  @moduledoc """
  Quick and dirty conveniences for working with utf8 encoded vtt files.
  """

  alias Vttyl.Part

  @doc """
  Parse a string.

  This drops badly formatted vtt files. Consult your local doctor to ensure you formatted it correctly.

  This returns a stream so you decide how to handle it!
  """
  @spec parse(String.t()) :: Enumerable.t()
  def parse(content) do
    content
    |> String.splitter("\n")
    |> do_parse()
  end

  @doc """
  Parse a stream of utf8 encoded characters.

  This returns a stream so you decide how to handle it!
  """
  @spec parse_stream(Enumerable.t()) :: Enumerable.t()
  def parse_stream(content) do
    content
    |> Stream.transform("", &next_line/2)
    |> do_parse()
  end

  defp do_parse(enum_content) do
    enum_content
    |> Stream.map(fn line -> Regex.replace(~r/#.*/, line, "") end)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 in ["", "WEBVTT"]))
    |> Stream.chunk_while(%Part{}, &parse_chunk/2, &parse_chunk_after/1)
    |> Stream.filter(&full_chunk?/1)
  end

  defp parse_chunk(line, acc) do
    acc =
      cond do
        Regex.match?(~r/^\d+$/, line) ->
          %Part{acc | part: String.to_integer(line)}

        not is_nil(acc.part) and timestamps?(line) ->
          {start_ts, end_ts} = parse_timestamps(line)

          %Part{acc | start: start_ts, end: end_ts}

        # Text content should be on one line and the other stuff should have appeared
        not is_nil(acc.part) and not is_nil(acc.start) and not is_nil(acc.end) and line != "" ->
          %Part{acc | text: line}

        true ->
          acc
      end

    if full_chunk?(acc) do
      {:cont, acc, %Part{}}
    else
      {:cont, acc}
    end
  end

  defp parse_chunk_after(acc) do
    if full_chunk?(acc) do
      {:cont, acc, %Part{}}
    else
      {:cont, acc}
    end
  end

  defp full_chunk?(%Part{part: part, start: start, end: ts_end, text: text}) do
    not is_nil(part) and not is_nil(start) and not is_nil(ts_end) and not is_nil(text)
  end

  @ts_pattern ~S"(?:(\d{2,}):)?(\d{2}):(\d{2})\.(\d{3})"
  @line_regex ~r/#{@ts_pattern} --> #{@ts_pattern}/
  @ts_regex ~r/#{@ts_pattern}/

  # 00:00:00.000 --> 00:01:01.000
  defp timestamps?(line) do
    Regex.match?(@line_regex, line)
  end

  defp parse_timestamps(line) do
    line
    |> String.split("-->")
    |> Enum.map(fn ts ->
      ts = String.trim(ts)
      [hour, minute, second, millisecond] = Regex.run(@ts_regex, ts, capture: :all_but_first)

      case hour do
        "" -> 0
        hour -> String.to_integer(hour) * 3_600_000
      end +
        String.to_integer(minute) * 60_000 +
        String.to_integer(second) * 1_000 +
        String.to_integer(millisecond)
    end)
    |> List.to_tuple()
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
end
