defmodule VttylTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Vttyl

  alias Vttyl.Part

  @expected_result [
    %Part{
      end: 17609,
      part: 1,
      start: 15450,
      text: "Hello"
    },
    %Part{
      end: 21240,
      part: 2,
      start: 20700,
      text: "Hi"
    },
    %Part{
      end: 64470,
      part: 3,
      start: 53970,
      text: "My name is Andy."
    },
    %Part{
      end: 76380,
      part: 4,
      start: 68040,
      text: "What a coincidence! Mine is too."
    }
  ]
  def get_vtt_file(file_name) do
    :vttyl
    |> :code.priv_dir()
    |> Path.join(["samples", "/#{file_name}"])
  end

  describe "parse/1" do
    test "success" do
      parsed = "small.vtt" |> get_vtt_file() |> File.read!() |> Vttyl.parse() |> Enum.into([])
      assert parsed == @expected_result
    end
  end

  describe "parse_stream/1" do
    test "success" do
      parsed =
        "small.vtt"
        |> get_vtt_file()
        |> File.stream!([], 2048)
        |> Vttyl.parse_stream()
        |> Enum.into([])

      assert parsed == @expected_result
    end

    test "success (small amount of bytes)" do
      parsed =
        "small.vtt"
        |> get_vtt_file()
        |> File.stream!([], 12)
        |> Vttyl.parse_stream()
        |> Enum.into([])

      assert parsed == @expected_result
    end

    test "success, longer" do
      parsed =
        "medium.vtt"
        |> get_vtt_file()
        |> File.stream!([], 2048)
        |> Vttyl.parse_stream()
        |> Enum.into([])

      assert length(parsed) == 20
    end

    test "voice spans" do
      parsed =
        "voice.vtt"
        |> get_vtt_file()
        |> File.stream!([], 2048)
        |> Vttyl.parse_stream()
        |> Stream.map(& &1.voice)
        |> Enum.into([])

      assert ["Esme", "Mary", "Esme F", "Mary"] == parsed
    end
  end

  describe "encode_vtt/1" do
    setup tags do
      part = %Part{
        part: Map.get(tags, :part, 1),
        start: Map.get(tags, :start, 1000),
        end: Map.get(tags, :end, 10_000),
        text: Map.get(tags, :text, "Hello world")
      }

      {:ok, %{parts: [part]}}
    end

    def make_vtt(part, start_ts, end_ts, text) do
      "WEBVTT\n\n#{part}\n#{start_ts} --> #{end_ts}\n#{text}\n"
    end

    test "basic", %{parts: parts} do
      assert make_vtt(1, "00:01.000", "00:10.000", "Hello world") == Vttyl.encode_vtt(parts)
    end

    @tag start: 100_000_000
    @tag end: 100_100_001
    test "large numbers", %{parts: parts} do
      assert make_vtt(1, "27:46:40.000", "27:48:20.001", "Hello world") == Vttyl.encode_vtt(parts)
    end
  end

  describe "encode_srt/1" do
    setup tags do
      part = %Part{
        part: Map.get(tags, :part, 1),
        start: Map.get(tags, :start, 1000),
        end: Map.get(tags, :end, 10_000),
        text: Map.get(tags, :text, "Hello world")
      }

      {:ok, %{parts: [part]}}
    end

    def make_srt(part, start_ts, end_ts, text) do
      "#{part}\n#{start_ts} --> #{end_ts}\n#{text}\n"
    end

    test "basic", %{parts: parts} do
      assert make_srt(1, "00:01,000", "00:10,000", "Hello world") == Vttyl.encode_srt(parts)
    end

    test "multi line" do
      parts = [
        %Part{
          part: 1,
          start: 1000,
          end: 10_000,
          text: "Hello"
        },
        %Part{
          part: 2,
          start: 2000,
          end: 20_000,
          text: "world"
        }
      ]

      expect =
        make_srt(1, "00:01,000", "00:10,000", "Hello") <>
          "\n" <> make_srt(2, "00:02,000", "00:20,000", "world")

      assert expect == Vttyl.encode_srt(parts)
    end

    @tag start: 100_000_000
    @tag end: 100_100_001
    test "large numbers", %{parts: parts} do
      assert make_srt(1, "27:46:40,000", "27:48:20,001", "Hello world") == Vttyl.encode_srt(parts)
    end
  end
end
