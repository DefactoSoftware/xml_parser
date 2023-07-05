defmodule XmlParserTest do
  use ExUnit.Case

  test "init returns opts" do
    assert Plug.Parsers.XML.init(foo: :bar) == [foo: :bar]
  end

  test "parses xml" do
    assert {:ok, %{xml: [%{name: :foo, value: ["bar"], attr: [baz: "true"]}]}, %Plug.Conn{}} =
             Plug.Parsers.XML.parse(
               %Plug.Conn{adapter: {__MODULE__, %{req_body: "<foo baz='true'>bar</foo>"}}},
               :type,
               "xml",
               :headers,
               xml_decoder: :xmerl_scan
             )
  end

  def read_req_body(%{req_body: body}, _opts), do: {:ok, body, :_}
end
