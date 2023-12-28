defmodule Teiserver.Config do
  @moduledoc """
  Config struct
  As with most things at this stage, heavily copied from Oban
  """

  alias Teiserver.Validation

  @type t :: %__MODULE__{
          log: false | Logger.level(),
          name: Teiserver.name(),
          node: String.t(),
          prefix: false | String.t(),
          repo: module()
        }

  defstruct log: false,
            name: Teiserver,
            node: nil,
            prefix: "public",
            repo: nil

  @log_levels ~w(false emergency alert critical error warning warn notice info debug)a

  @doc """
  Generate a Config struct after normalizing and verifying Teiserver options.

  See `Teiserver.start_link/1` for a comprehensive description of available options.

  ## Example

  Generate a minimal config with only a `:repo`:

      Teiserver.Config.new(repo: Teiserver.Test.Repo)
  """
  @spec new([Teiserver.option()]) :: t()
  def new(opts) when is_list(opts) do
    opts = normalize(opts)

    with {:error, reason} <- validate(opts) do
      raise ArgumentError, reason
    end

    struct!(__MODULE__, opts)
  end

  @doc """
  Verify configuration options.

  This helper is used by `new/1`, and therefore by `Teiserver.start_link/1`, to verify configuration
  options when a Teiserver supervisor starts. It is provided publicly to aid in configuration testing,
  as `test` config may differ from `prod` config.

  # Example

  Validating top level options:

      iex> Teiserver.Config.validate(name: Teiserver)
      :ok

      iex> Teiserver.Config.validate(name: Teiserver, log: false)
      :ok

      iex> Teiserver.Config.validate(node: {:not, :binary})
      {:error, "expected :node to be a binary, got: {:not, :binary}"}

  Validating plugin options:

      iex> Teiserver.Config.validate(plugins: [{Teiserver.Plugins.Pruner, max_age: 60}])
      :ok

      iex> Teiserver.Config.validate(plugins: [{Teiserver.Plugins.Pruner, max_age: 0}])
      {:error, "invalid value for :plugins, expected :max_age to be a positive integer, got: 0"}
  """
  @spec validate([Teiserver.option()]) :: :ok | {:error, String.t()}
  def validate(opts) when is_list(opts) do
    opts = normalize(opts)

    Validation.validate_schema(opts,
      log: {:enum, @log_levels},
      name: :any,
      node: {:pattern, ~r/^\S+$/},
      prefix: {:or, [:falsy, :string]},
      repo: {:behaviour, Ecto.Repo}
    )
  end

  @doc false
  @spec node_name(%{optional(binary()) => binary()}) :: binary()
  def node_name(env \\ System.get_env()) do
    cond do
      Node.alive?() ->
        to_string(node())

      Map.has_key?(env, "DYNO") ->
        Map.get(env, "DYNO")

      true ->
        :inet.gethostname()
        |> elem(1)
        |> to_string()
    end
  end

  defp normalize(opts) do
    opts
    |> Keyword.put_new(:node, node_name())
  end
end
