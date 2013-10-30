defmodule ExVCR.Mock do
  @moduledoc """
  Provides macro to record HTTP request/response.
  It only supports :ibrowse HTTP library at the moment.
  """
  alias ExVCR.Recorder

  defmacro use_cassette(fixture, options // [], test) do
    :application.ensure_started(:ibrowse)
    quote do
      :meck.new(:ibrowse, [:passthrough])
      recorder = Recorder.start(unquote(fixture), unquote(options))
      ExVCR.Mock.IBrowse.mock_methods(recorder)

      try do
        unquote(test)
        if Mix.env == :test do
          if :meck.validate(:ibrowse) == false, do: raise ":meck.validate failed"
        end
      after
        :meck.unload(:ibrowse)
        Recorder.save(recorder)
      end
    end
  end
end
