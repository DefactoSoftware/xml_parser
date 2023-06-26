defmodule Plug.Parsers.XML do
  @behaviour Plug.Parsers
  import Plug.Conn

  def init(opts), do: opts

  def parse(conn, _, "xml", _headers, opts) do
    decoder =
      Keyword.get(opts, :xml_decoder) ||
        raise ArgumentError, "XML parser expects a :xml_decoder option"

    conn
    |> read_body(opts)
    |> decode(decoder)
  end

  def parse(conn, _type, subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:ok, body, conn}, decoder) do
    case body |> :erlang.bitstring_to_list() |> decoder.string() do
      {parsed, []} ->
        parsed = parse_record(parsed, [])
        {:ok, %{xml: parsed}, conn}

      error ->
        raise "Malformed XML #{error}"
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end

  defp combine_values([]), do: []

  defp combine_values(values) do
    if Enum.all?(values, &is_binary(&1)) do
      [List.to_string(values)]
    else
      values
    end
  end

  defp parse_record({:xmlElement, name, _, _, _, _, _, attributes, elements, _, _, _}, options) do
    value = combine_values(parse_record(elements, options))
    name = parse_name(name, options)
    [%{name: name, attr: parse_attribute(attributes), value: value}]
  end

  defp parse_record({:xmlText, _, _, _, value, _}, _) do
    string_value = String.trim(to_string(value))

    if String.length(string_value) > 0 do
      [string_value]
    else
      []
    end
  end

  defp parse_record({:xmlComment, _, _, _, value}, options) do
    if options[:comments] do
      [%{name: :comments, attr: [], value: String.trim(to_string(value))}]
    else
      []
    end
  end

  defp parse_record([], _), do: []

  defp parse_record([head | tail], options) do
    parse_record(head, options) ++ parse_record(tail, options)
  end

  defp parse_attribute([]), do: []

  defp parse_attribute({:xmlAttribute, name, _, _, _, _, _, _, value, _}) do
    [{name, to_string(value)}]
  end

  defp parse_attribute([head | tail]) do
    parse_attribute(head) ++ parse_attribute(tail)
  end

  defp parse_name(name, %{strip_namespaces: true}) do
    name
    |> to_string
    |> String.split(":")
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end

  defp parse_name(name, _), do: name
end
