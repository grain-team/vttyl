defmodule Vttyl.Header do
  @type t :: %__MODULE__{
          values: [{String.t(), String.t()}]
        }
  defstruct values: []
end
