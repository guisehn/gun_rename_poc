defmodule Renamer do
  @original_path "priv/original"

  @renamed_path "priv/renamed"
  @renamed_src "#{@renamed_path}/src"
  @renamed_tests "#{@renamed_path}/test"

  def rename_all do
    File.rm_rf(@renamed_path)
    File.cp_r!(@original_path, @renamed_path)

    modules =
      "#{@renamed_src}/*.erl"
      |> Path.wildcard()

    modules
    |> Enum.with_index()
    |> Enum.each(fn {file, i} ->
      from = file |> Path.basename() |> String.replace_trailing(".erl", "")
      to = String.replace_leading(from, "gun", "gun2") # gun* -> gun2*
      IO.puts("#{i + 1}/#{length(modules)}: Renaming module #{from} to #{to}...")
      rename_module(from, to)
    end)

    # TODO: gun.app.src
    # TODO: erlang.mk
    # TODO: mix.exs
  end

  defp rename_module(from, to) when is_binary(from) and is_binary(to),
    do: rename_module(String.to_atom(from), String.to_atom(to))

  defp rename_module(from, to) when is_atom(from) and is_atom(to) do
    File.rename!("#{@renamed_src}/#{from}.erl", "#{@renamed_src}/#{to}.erl")

    # rename -module(from). to -module(to).
    updated =
      "#{@renamed_src}/#{to}.erl"
      |> read()
      |> map(&replace_module(&1, from, to))
      |> to_code()
    File.write!("#{@renamed_src}/#{to}.erl", updated)

    # rename atom on all other modules to point to renamed module
    for wildcard <- ["#{@renamed_src}/*.erl", "#{@renamed_tests}/**/*.erl"] do
      wildcard
      |> Path.wildcard()
      |> Enum.each(fn file ->
        updated =
          replace_atom_in_file(file, from, to)
          |> to_code()

        File.write!(file, updated)
      end)
    end
  end

  defp replace_atom_in_file(file, from, to) do
    file
    |> read()
    |> map(&replace_atom(&1, from, to))
  end

  defp read(file), do: file |> String.to_charlist() |> :forms.read()

  defp map(forms, fun), do: :forms.map(fun, forms)

  defp replace_atom({:atom, n, from}, from, to), do: {:atom, n, to}
  defp replace_atom(item, _, _), do: item

  defp to_code(forms) do
    forms
    |> :forms.from_abstract()
    |> List.to_string()
    |> remove_file_attribute()
  end

  # remove `-file().` attribute added by :forms on the start of the file
  defp remove_file_attribute(str), do: remove_first_lines(str, 2)

  defp remove_first_lines(str, n), do: str |> String.split("\n") |> Enum.drop(n) |> Enum.join("\n")

  defp replace_module({:attribute, n, :module, from}, from, to), do: {:attribute, n, :module, to}
  defp replace_module(item, _, _), do: item
end
