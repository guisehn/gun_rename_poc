defmodule Gun.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gun,
      version: "2.0.0",
      description: description(),
      deps: deps(),
      package: package()
    ]
  end

  defp description do
    """
    HTTP/1.1, HTTP/2 and Websocket client for Erlang/OTP.
    """
  end

  defp deps do
    [
      {:cowlib, "~> 2.8.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "grpc_gun",
      maintainers: ["Loïc Hoguin"],
      licenses: ["ISC"],
      build_tools: ["rebar3"],
      links: %{
        "GitHub" => "https://github.com/elixir-grpc/gun",
        "Original GitHub" => "https://github.com/ninenines/gun"
      },
      files: ["erlang.mk", "LICENSE", "Makefile", "README.asciidoc", "rebar.config", "src"]
    ]
  end
end
