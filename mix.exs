defmodule XmlParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_plug_parser,
      deps: deps(),
      description: description(),
      elixir: "~> 1.6",
      elixirc_paths: ["lib"],
      name: "xml_plug_parser",
      package: package(),
      source_url: "https://github.com/defactosoftware/xml_parser",
      start_permanent: false,
      version: "0.0.1"
    ]
  end

  defp package do
    [
      name: :xml_plug_parser,
      maintainers: ["Richard van der Veen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/defactosoftware/xml_parser"}
    ]
  end

  defp description do
    """
    A module to parse XML using Plug.
    """
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:plug, "~> 1.0"}
    ]
  end
end
