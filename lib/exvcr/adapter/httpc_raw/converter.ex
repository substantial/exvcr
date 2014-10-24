defmodule ExVCR.Adapter.HttpcRaw.Converter do
  @moduledoc """
  Provides helpers to mock :httpc methods avoiding conversions.
  """

  use ExVCR.Converter

  defp string_to_response(response) do
    response
  end

  defp request_to_string([url]) do
    request_to_string([:get, {url, [], [], []}, [], []])
  end
  defp request_to_string([method, {url, headers}, http_options, options]) do
    request_to_string([method, {url, headers, [], []}, http_options, options])
  end

  # TODO: need to handle content_type
  defp request_to_string([method, {url, headers, _content_type, body}, http_options, options]) do
    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(headers),
      method: method,
      body: parse_request_body(body),
      options: [httpc_options: options, http_options: http_options]
    }
  end

  defp response_to_string({:ok, {{http_version, status_code, reason_phrase}, headers, body}}) do
    %ExVCR.Response{
      type: "ok",
      status_code: [http_version, status_code, reason_phrase],
      headers: parse_headers(headers),
      body: body
    }
  end

  defp response_to_string({:error, {reason, _detail}}) do
    %ExVCR.Response{
      type: "error",
      body: reason
    }
  end

  defp parse_headers(headers) do
    do_parse_headers(headers, [])
  end

  defp do_parse_headers([], acc), do: Enum.reverse(acc)
  defp do_parse_headers([{key,value}|tail], acc) do
    replaced_value = value |> ExVCR.Filter.filter_sensitive_data
    do_parse_headers(tail, [{key, replaced_value}|acc])
  end

  defp parse_request_body(body) do
    body |> ExVCR.Filter.filter_sensitive_data
  end
end
