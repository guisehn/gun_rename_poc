defmodule Mix.Tasks.Rename do
  use Mix.Task

  def run(_) do
    Renamer.rename_all()
  end
end
