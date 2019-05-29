defmodule Vttyl.Part do
  @type t :: %__MODULE__{
          part: non_neg_integer(),
          start: Time.t(),
          end: Time.t(),
          text: String.t()
        }
  defstruct [:start, :end, :text, :part]
end
