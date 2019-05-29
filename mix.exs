defmodule Vttyl.MixProject do
  use Mix.Project

  @version "0.1.0"
  @repo_url "https://github.com/grain-team/vttyl"

  def project do
    [
      app: :vttyl,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: package(),
      description: "A dead simple vtt parser.",

      # Docs
      name: "Vttyl",
      docs: [
        source_ref: "v#{@version}",
        source_url: @repo_url
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.20", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false}
    ]
  end
end
