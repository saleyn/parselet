defmodule Datum.Component do
  @moduledoc """
  Defines the behaviour and DSL for Datum components.
  """

  defmacro __using__(_opts) do
    quote do
      import Datum.Component
      Module.register_attribute(__MODULE__, :datum_fields, accumulate: true)
      @before_compile Datum.Component
    end
  end

  defmacro field(name, opts) do
    quote do
      @datum_fields {unquote(name), unquote(Macro.escape(opts))}
    end
  end

  defmacro __before_compile__(env) do
    fields =
      Module.get_attribute(env.module, :datum_fields)
      |> Enum.map(fn {name, opts} ->
        quote do
          {unquote(name), Datum.Field.new(unquote(name), unquote(opts))}
        end
      end)

    quote do
      def __datum_fields__ do
        %{
          unquote_splicing(fields)
        }
      end
    end
  end
end
