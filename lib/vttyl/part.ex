defmodule Vttyl.Part do
  @type t :: %__MODULE__{
          part: non_neg_integer(),
          start: millisecond :: integer,
          end: millisecond :: integer,
          text: String.t(),
          voice: String.t() | nil,
          settings: [{String.t(), String.t()}]
        }
  defstruct start: nil, end: nil, text: nil, part: nil, voice: nil, settings: []
end
