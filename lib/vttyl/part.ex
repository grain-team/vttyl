defmodule Vttyl.Part do
  @type t :: %__MODULE__{
          part: non_neg_integer(),
          start: millisecond :: integer,
          end: millisecond :: integer,
          text: String.t()
        }
  defstruct [:start, :end, :text, :part]
end
