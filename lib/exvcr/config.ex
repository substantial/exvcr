defmodule ExVCR.Config do
  @moduledoc """
  Store configurations for libraries.
  """

  alias ExVCR.Setting

  @doc """
  Initializes library dir to store cassette files.
    - vcr_dir: directory for storing recorded file.
    - custom_dir: directory for placing custom file.
  """
  def cassette_library_dir(vcr_dir, custom_dir \\ nil) do
    Setting.set(:cassette_library_dir, vcr_dir)
    File.mkdir_p!(vcr_dir)

    Setting.set(:custom_library_dir, custom_dir)
    :ok
  end

  @doc """
  Replace the specified pattern with placeholder.
  It can be used to remove sensitive data from the casette file.
  """
  def filter_sensitive_data(pattern, placeholder) do
    Setting.append(:filter_sensitive_data, {pattern, placeholder})
  end

  @doc """
  Clear the previously specified filter_sensitive_data lists.
  """
  def filter_sensitive_data(nil) do
    Setting.set(:filter_sensitive_data, [])
  end

  @doc """
  Set the flag whether to filter-out url params when recording to cassettes.
  (ex. if flag is true, "param=val" is removed from "http://example.com?param=val").
  """
  def filter_url_params(flag) do
    Setting.set(:filter_url_params, flag)
  end

  @doc """
  Sets a list of headers to remove from the response
  """
  def response_headers_blacklist(headers_blacklist) do
    blacklist = Enum.map(headers_blacklist, fn(x) -> String.downcase(x) end)
    Setting.set(:response_headers_blacklist, blacklist)
  end

  @doc """
  Set the cassettes formatter to json as it is by default.
  """
  def format(:json) do
    Setting.set(:format, "json")
    Setting.set(:format_module, ExVCR.JSON)
  end

  @doc """
  Set the cassettes formatter to raw Erlang.
  """
  def format(:raw) do
    Setting.set(:format, "raw")
    Setting.set(:format_module, ExVCR.Marshal)
  end
end
