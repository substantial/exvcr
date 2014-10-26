defmodule ExVCR.RecorderBaseTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock
  alias ExVCR.Recorder

  test "initializes recorder" do
    record = Recorder.start(options)
    assert ExVCR.Actor.Options.get(record.options)     == options
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "test append/pop of recorder" do
    record = Recorder.start(options)
    Recorder.append(record, "test")
    assert Recorder.pop(record) == "test"
  end

  defp options do
    [test: true, fixture: "fixture/tmp", adapter: ExVCR.Adapter.IBrowse]
  end
end
