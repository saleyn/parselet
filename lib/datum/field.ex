defmodule Datum.Field do
  @moduledoc false

  defstruct [:name, :pattern, :capture, :transform, :function, required: false]

  def new(name, opts) do
    %__MODULE__{
      name: name,
      pattern: Keyword.get(opts, :pattern),
      capture: Keyword.get(opts, :capture, :first),
      transform: Keyword.get(opts, :transform, & &1),
      function: Keyword.get(opts, :function),
      required: Keyword.get(opts, :required, false)
    }
  end

  def extract(%__MODULE__{function: fun}, text) when is_function(fun, 1) do
    fun.(text)
  end

  def extract(%__MODULE__{pattern: nil}, _text), do: nil

  def extract(%__MODULE__{pattern: pattern, capture: :first, transform: t}, text) do
    case Regex.run(pattern, text, capture: :all_but_first) do
      [value] -> t.(value)
      _ -> nil
    end
  end

  def extract(%__MODULE__{pattern: pattern, capture: :all, transform: t}, text) do
    case Regex.run(pattern, text, capture: :all_but_first) do
      values when is_list(values) -> t.(values)
      _ -> nil
    end
  end

  def validate_required(fields_map, fields_struct_map) do
    fields_struct_map
    |> Enum.filter(fn {_name, field} -> field.required end)
    |> Enum.map(fn {name, _field} -> name end)
    |> Enum.filter(&(!Map.has_key?(fields_map, &1)))
  end
end
