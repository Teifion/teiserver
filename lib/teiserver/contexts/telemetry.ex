defmodule Teiserver.Telemetry do
  require Logger

  @handler_id "teiserver-default-logger"

  @doc """
  Attaches a default structured JSON Telemetry handler for logging.

  This function attaches a handler that outputs logs with the following fields for job events:

  * `args` — a map of the job's raw arguments
  * `attempt` — the job's execution atttempt
  * `duration` — the job's runtime duration, in the native time unit
  * `event` — `job:start`, `job:stop`, `job:exception` depending on reporting telemetry event
  * `error` — a formatted error banner, without the extended stacktrace
  * `id` — the job's id
  * `meta` — a map of the job's raw metadata
  * `queue` — the job's queue
  * `source` — always "teiserver"
  * `state` — the execution state, one of "success", "failure", "cancelled", "discard", or
    "snoozed"
  * `system_time` — when the job started, in microseconds
  * `tags` — the job's tags
  * `worker` — the job's worker module

  And the following fields for stager events:

  * `event` — always `stager:switch`
  * `message` — information about the mode switch
  * `mode` — either `"local"` or `"global"`
  * `source` — always "teiserver"

  ## Options

  * `:level` — The log level to use for logging output, defaults to `:info`
  * `:encode` — Whether to encode log output as JSON, defaults to `true`

  ## Examples

  Attach a logger at the default `:info` level with JSON encoding:

      :ok = Teiserver.Telemetry.attach_default_logger()

  Attach a logger at the `:debug` level:

      :ok = Teiserver.Telemetry.attach_default_logger(level: :debug)

  Attach a logger with JSON logging disabled:

      :ok = Teiserver.Telemetry.attach_default_logger(encode: false)
  """
  @spec attach_default_logger(Logger.level() | Keyword.t()) :: :ok | {:error, :already_exists}
  def attach_default_logger(opts \\ [encode: true, level: :info])

  def attach_default_logger(level) when is_atom(level) do
    attach_default_logger(level: level)
  end

  def attach_default_logger(opts) when is_list(opts) do
    events = event_list()

    opts =
      opts
      |> Keyword.put_new(:encode, true)
      |> Keyword.put_new(:level, :info)

    :telemetry.attach_many(@handler_id, events, &__MODULE__.handle_event/4, opts)
  end

  @spec event_list() :: list(list(atom))
  def event_list() do
    [
      # User
      [:teiserver, :user, :failed_login],

      # Client
      [:teiserver, :client, :connect],
      [:teiserver, :client, :disconnect],
      [:teiserver, :client, :updated],
      [:teiserver, :client, :updated_in_lobby],

      # Lobby
      [:teiserver, :lobby, :start_match],
      [:teiserver, :lobby, :cycle],
      [:teiserver, :lobby, :add_client],
      [:teiserver, :lobby, :remove_client],

      # Logging
      [:teiserver, :logging, :add_audit_log]
    ]
  end

  @doc """
  Undoes `Teiserver.Telemetry.attach_default_logger/1` by detaching the attached logger.

  ## Examples

  Detach a previously attached logger:

      :ok = Teiserver.Telemetry.attach_default_logger()
      :ok = Teiserver.Telemetry.detach_default_logger()

  Attempt to detach when a logger wasn't attached:

      {:error, :not_found} = Teiserver.Telemetry.detach_default_logger()
  """
  @doc since: "2.15.0"
  @spec detach_default_logger() :: :ok | {:error, :not_found}
  def detach_default_logger do
    :telemetry.detach(@handler_id)
  end

  @doc false
  @spec handle_event([atom()], map(), map(), Keyword.t()) :: :ok
  # def handle_event([:teiserver, :job, event], measure, meta, opts) do
  #   log(opts, fn ->
  #     details = Map.take(meta.job, ~w(attempt args id max_attempts meta queue tags worker)a)

  #     extra =
  #       case event do
  #         :start ->
  #           %{event: "job:start", system_time: measure.system_time}

  #         :stop ->
  #           %{
  #             duration: convert(measure.duration),
  #             event: "job:stop",
  #             queue_time: convert(measure.queue_time),
  #             state: meta.state
  #           }

  #         :exception ->
  #           %{
  #             error: Exception.format_banner(meta.kind, meta.reason, meta.stacktrace),
  #             event: "job:exception",
  #             duration: convert(measure.duration),
  #             queue_time: convert(measure.queue_time),
  #             state: meta.state
  #           }
  #       end

  #     Map.merge(details, extra)
  #   end)
  # end

  # def handle_event([:teiserver, :stager, :switch], _measure, %{mode: mode}, opts) do
  #   log(opts, fn ->
  #     case mode do
  #       :local ->
  #         %{
  #           event: "stager:switch",
  #           mode: "local",
  #           message:
  #             "job staging switched to local mode. local mode polls for jobs for every queue; " <>
  #               "restore global mode with a functional notifier"
  #         }

  #       :global ->
  #         %{
  #           event: "stager:switch",
  #           mode: "global",
  #           message: "job staging switched back to global mode"
  #         }
  #     end
  #   end)
  # end

  def handle_event([:teiserver, a, b], measure, meta, opts) do
    IO.puts("#{__MODULE__}:#{__ENV__.line}")
    IO.inspect({{a, b}, measure, meta, opts})
    IO.puts("")

    # log(opts, fn ->
    #   case mode do
    #     :local ->
    #       %{
    #         event: "stager:switch",
    #         mode: "local",
    #         message:
    #           "job staging switched to local mode. local mode polls for jobs for every queue; " <>
    #             "restore global mode with a functional notifier"
    #       }

    #     :global ->
    #       %{
    #         event: "stager:switch",
    #         mode: "global",
    #         message: "job staging switched back to global mode"
    #       }
    #   end
    # end)
  end

  # defp log(opts, fun) do
  #   level = Keyword.fetch!(opts, :level)

  #   Logger.log(level, fn ->
  #     output = Map.put(fun.(), :source, "teiserver")

  #     if Keyword.fetch!(opts, :encode) do
  #       Jason.encode_to_iodata!(output)
  #     else
  #       output
  #     end
  #   end)
  # end

  # defp convert(value), do: System.convert_time_unit(value, :native, :microsecond)
end
