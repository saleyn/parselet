defmodule Datum do
  @moduledoc """
  Main entry point for parsing text using Datum components.
  """

  def parse(text, components: components) do
    parse_impl(text, components)
  end

  def parse!(text, components: components) do
    result = parse_impl(text, components)

    all_fields =
      components
      |> Enum.flat_map(fn component ->
        component.__datum_fields__()
      end)
      |> Enum.into(%{})

    case Datum.Field.validate_required(result, all_fields) do
      [] -> result
      missing -> raise ArgumentError, "Missing required fields: #{inspect(missing)}"
    end
  end

  defp parse_impl(text, components) do
    components
    |> Enum.flat_map(fn component ->
      component.__datum_fields__()
      |> Enum.map(fn {name, field} ->
        {name, Datum.Field.extract(field, text)}
      end)
    end)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end
end
