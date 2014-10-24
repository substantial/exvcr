defmodule ExVCR.Marshal do
  @moduledoc """
  Provides a feature to store/load cassettes in Erlang format.
  """

  @doc """
  Save responses into the Erlang file.
  """
  def save(file_name, responses) do
    unless File.exists?(path = Path.dirname(file_name)), do: File.mkdir_p(path)
    io_device = File.open!(file_name, [:write, {:encoding, :utf8}])
    rev_responses = responses |> Enum.reverse
    :io.format(io_device, '~w.', [rev_responses])
    File.close(io_device)
  end

  @doc """
  Loads the files based on the fixture name and options.
  For options, this method just refers to the :custom attribute is set or not.
  """
  def load(file_name, custom_mode, adapter) do
    case { File.exists?(file_name), custom_mode } do
      { true, _ } -> read_raw_file(file_name)
      { false, true } -> raise %ExVCR.FileNotFoundError{message: "cassette file \"#{file_name}\" not found"}
      { false, _ } -> []
    end
  end

  @doc """
  Reads and parse the Erlang file located at the specified file_name.
  """
  defp read_raw_file(file_name) do
    {:ok, tokens, _} = File.read!(file_name) |> :erlang.binary_to_list |> :erl_scan.string
    {:ok, [expr|_]} = :erl_parse.parse_exprs(tokens)
    {:value, responses, _} = :erl_eval.expr(expr, :orddict.new())
    responses
  end
end
