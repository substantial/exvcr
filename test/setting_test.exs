defmodule ExVCR.SettingTest do
  use ExUnit.Case, async: false

  setup_all do
    cassette_library_dir = ExVCR.Setting.get(:cassette_library_dir)
    custom_library_dir   = ExVCR.Setting.get(:custom_library_dir)

    on_exit(fn ->
      ExVCR.Setting.set(:cassette_library_dir, cassette_library_dir)
      ExVCR.Setting.set(:custom_library_dir, custom_library_dir)
      :ok
    end)
    :ok
  end

  test "set custom_library_dir" do
    ExVCR.Setting.set(:custom_library_dir, "custom_dummy")
    assert ExVCR.Setting.get(:custom_library_dir) == "custom_dummy"
  end

  test "set cassette_library_dir" do
    ExVCR.Setting.set(:cassette_library_dir, "cassette_dummy")
    assert ExVCR.Setting.get(:cassette_library_dir) == "cassette_dummy"
  end

  test "set response_headers_blacklist" do
    ExVCR.Setting.set(:response_headers_blacklist, ["Content-Type", "Accept"])
    assert ExVCR.Setting.get(:response_headers_blacklist) == ["Content-Type", "Accept"]
  end

  test "set format" do
    ExVCR.Setting.set(:format, "erl")
    assert ExVCR.Setting.get(:format) == "erl"
  end

  test "set format_module" do
    ExVCR.Setting.set(:format_module, ExVCR.Marshal)
    assert ExVCR.Setting.get(:format_module) == ExVCR.Marshal
  end
end
