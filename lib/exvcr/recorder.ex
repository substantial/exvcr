defmodule ExVCR.Recorder do
  @moduledoc """
  Provides data saving/loading capability for HTTP interactions.
  """

  alias ExVCR.Handler
  alias ExVCR.Actor.Responses
  alias ExVCR.Actor.Options

  @doc """
  Initialize recorder.
  """
  def start(options) do
    ExVCR.Checker.start([])

    {:ok, act_responses} = Responses.start([])
    {:ok, act_options}   = Options.start(options)

    recorder = %ExVCR.Record{options: act_options, responses: act_responses}

    if stub = options(recorder)[:stub] do
      set(stub, recorder)
    else
      load(recorder)
    end

    recorder
  end

  @doc """
  Provides entry point to be called from :meck library. HTTP request arguments are specified as args parameter.
  If response is not found in the cache, access to the server.
  """
  def request(recorder, request) do
    Handler.get_response(recorder, request)
  end

  @doc """
  Load record-data from a file.
  """
  def load(recorder) do
    file_path   = get_file_path(recorder)
    custom_mode = options(recorder)[:custom]
    adapter     = options(recorder)[:adapter]
    responses   = adapter.serializer.load(file_path, custom_mode, adapter)
    set(responses, recorder)
  end

  @doc """
  Save record-data into a file.
  """
  def save(recorder) do
    file_path = get_file_path(recorder)
    if File.exists?(file_path) == false do
      adapter = options(recorder)[:adapter]
      adapter.serializer.save(file_path, ExVCR.Recorder.get(recorder))
    end
  end

  @doc """
  Returns the file path of the save/load target, based on the custom_mode(true or false).
  """
  def get_file_path(recorder) do
    opts = options(recorder)
    adapter = opts[:adapter]
    directory = case opts[:custom] do
      true  -> ExVCR.Setting.get(:custom_library_dir)
      _     -> ExVCR.Setting.get(:cassette_library_dir)
    end
    "#{directory}/#{opts[:fixture]}.#{adapter.serializer.format}"
  end

  def options(recorder),        do: Options.get(recorder.options)
  def get(recorder),            do: Responses.get(recorder.responses)
  def set(responses, recorder), do: Responses.set(recorder.responses, responses)
  def append(recorder, x),      do: Responses.append(recorder.responses, x)
  def pop(recorder),            do: Responses.pop(recorder.responses)

  def update(recorder, finder, updator) do
    responses = Enum.map(ExVCR.Recorder.get(recorder), fn(response) ->
      if finder.(response) do
        updator.(response)
      else
        response
      end
    end)
    set(responses, recorder)
  end
end
