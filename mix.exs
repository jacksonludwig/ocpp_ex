defmodule OcppEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :ocpp_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx],
      mod: {OcppEx, []},
      env: [central_system_url: "wss://ws.postman-echo.com/raw"],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:jason, "~> 1.4"},
      {:ex_json_schema, "~> 0.10.1"},
      {:typed_struct, "~> 0.1.4"}
    ]
  end
end
