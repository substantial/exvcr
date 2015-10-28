defmodule ExVCR.Adapter.HttpcRaw do
  @moduledoc """
  Provides adapter methods to mock :httpc_raw methods.
  """

  use ExVCR.Adapter

  defmacro __using__(_opts) do
    # do nothing
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.HttpcRaw.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.HttpcRaw.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :httpc
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
    TODO:
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2])}
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5])}
  """
  def target_methods(recorder) do
    [ {:request, &ExVCR.Recorder.request(recorder, [&1])},
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4])} ]
  end

  @doc """
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    if Enum.count(request) <= 2 do
      [url: Enum.fetch!(request, 0), method: :get]
    else
      url = Enum.fetch!(request, 1) |> elem(0)
      method = Enum.fetch!(request, 0)
      [url: url, method: method]
    end
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response) do
    filter_sensitive_data(response)
  end

  defp filter_sensitive_data({:ok, {status_code, headers, body}}) do
    replaced_body = body |> ExVCR.Filter.filter_sensitive_data
    {:ok, {status_code, headers, replaced_body}}
  end

  defp filter_sensitive_data({:error, reason}) do
    {:error, reason}
  end

  @doc """
  Returns the response from the ExVCR.Reponse record.
  """
  def get_response_value_from_cache(response) do
    if response.type == "error" do
      {:error, response.body}
    else
      {:ok, {response.status_code, response.headers, response.body}}
    end
  end

  @doc """
  Default definitions for stub.
  """
  def default_stub_params(:headers), do: %{"content-type" => "text/html"}
  def default_stub_params(:status_code), do: {"HTTP/1.1", 200, "OK"}

  @doc """
  Module used for persistence: ExVCR.Marshal.
  """
  def serializer, do: ExVCR.Marshal
end
