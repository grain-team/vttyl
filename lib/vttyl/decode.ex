defmodule Vttyl.Decode do
  @moduledoc false

  alias Vttyl.Part

  def parse(enum_content) do
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

        is_nil(acc.part) and timestamps?(line) ->
          {start_ts, end_ts} = parse_timestamps(line)
          %Part{acc | start: start_ts, end: end_ts, part: 0}

        not is_nil(acc.part) and timestamps?(line) ->
          {start_ts, end_ts} = parse_timestamps(line)

          %Part{acc | start: start_ts, end: end_ts}

        # Text content should be on one line and the other stuff should have appeared
        not is_nil(acc.part) and not is_nil(acc.start) and not is_nil(acc.end) and line != "" ->
          {voice, text} = parse_text(line)
          %Part{acc | text: text, voice: voice}

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

  @annotation_space_regex ~r/[ \t]/
  defp parse_text("<v" <> line) do
    [voice, text] = String.split(line, ">", parts: 2)
    [_, voice] = String.split(voice, @annotation_space_regex, parts: 2)
    {voice, text}
  end

  defp parse_text(text), do: {nil, text}

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
end
