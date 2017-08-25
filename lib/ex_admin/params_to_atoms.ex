defmodule ExAdmin.ParamsToAtoms do
  @moduledoc false
  require Logger

  def filter_params(params, schema) do
    params_to_atoms(params, schema)
  end

  def params_to_atoms(params, schema) do
    list = for {key, value} <- params do
      do_params_to_atoms(key, value, schema)
    end

    list
    |> Enum.reject(fn {_k, v} -> v == "" end)
    |> Enum.into(Map.new)
  end

  defp do_params_to_atoms(key, %Plug.Upload{} = value, _) do
    {_to_atom(key), value}
  end
  defp do_params_to_atoms(key, value, schema) when is_map(value) do
    key = _to_atom(key)
    case schema.__schema__(:type, key) do
      {:array, :map} -> {key, Map.values(value)}
      _ -> {key, params_to_atoms(value, schema)}
    end
  end
  defp do_params_to_atoms(key, value, _) do
    {_to_atom(key), value}
  end

  defp _to_atom(key) when is_atom(key), do: key
  defp _to_atom(key), do: String.to_atom(key)
end
