defmodule Vttyl.Encode do
  @moduledoc false
  alias Vttyl.Part

  @spec encode_part(Part.t(), :vtt | :srt) :: String.t()
  def encode_part(part, type) do
    ts = fmt_timestamp(part.start, type) <> " --> " <> fmt_timestamp(part.end, type)

    text =
      if type == :vtt && part.voice do
        "<v #{part.voice}>" <> part.text
      else
        part.text
      end

    Enum.join([part.part, ts, text], "\n")
  end

  @hour_ms 3_600_000
  @minute_ms 60_000
  defp fmt_timestamp(milliseconds, type) do
    {hours, ms_wo_hrs} = mod(milliseconds, @hour_ms)
    {minutes, ms_wo_mins} = mod(ms_wo_hrs, @minute_ms)

    # Lop off hours if there aren't any
    hr_and_min =
      if hours <= 0 do
        prefix_fmt(minutes)
      else
        [hours, minutes]
        |> Enum.map(&prefix_fmt/1)
        |> Enum.join(":")
      end

    hr_and_min <> ":" <> fmt_seconds(ms_wo_mins, type)
  end

  defp mod(dividend, divisor) do
    remainder = Integer.mod(dividend, divisor)
    quotient = (dividend - remainder) / divisor
    {trunc(quotient), remainder}
  end

  defp prefix_fmt(num) do
    num |> Integer.to_string() |> String.pad_leading(2, "0")
  end

  # Force seconds to have three decimal places and 0 padded in the front
  @second_ms 1000
  defp fmt_seconds(milliseconds, type) do
    [seconds, dec_part] =
      milliseconds
      |> Kernel./(@second_ms)
      |> Float.round(3)
      |> Float.to_string()
      |> String.split(".")

    seconds = String.pad_leading(seconds, 2, "0")
    ms_part = String.pad_trailing(dec_part, 3, "0")

    separator =
      if type == :srt do
        ","
      else
        "."
      end

    seconds <> separator <> ms_part
  end
end
