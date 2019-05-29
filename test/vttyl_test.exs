defmodule VttylTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest Vttyl

  alias Vttyl.Part

  @expected_result [
    %Part{
      end: ~T[00:00:17.609],
      part: 1,
      start: ~T[00:00:15.450],
      text: "Hello"
    },
    %Part{
      end: ~T[00:00:21.240],
      part: 2,
      start: ~T[00:00:20.700],
      text: "Hi"
    },
    %Part{
      end: ~T[00:01:04.470],
      part: 3,
      start: ~T[00:00:53.970],
      text: "My name is Andy."
    },
    %Part{
      end: ~T[00:01:16.380],
      part: 4,
      start: ~T[00:01:08.040],
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
      parsed = "small.vtt" |> get_vtt_file() |> File.read!() |> Vttyl.parse()
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
  end
end
