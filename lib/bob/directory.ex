defmodule Bob.Directory do
  @max_temp_dirs 100

  def new() do
    clean_temp_dirs()

    random =
      :crypto.strong_rand_bytes(16)
      |> Base.encode16(case: :lower)

    path = Path.join(Bob.tmp_dir(), random)
    File.rm_rf!(path)
    File.mkdir_p!(path)

    path
  end

  defp clean_temp_dirs() do
    Path.wildcard(Path.join(Bob.tmp_dir(), "*"))
    |> Enum.sort_by(&mtime/1, &>=/2)
    |> Enum.drop(@max_temp_dirs)
    |> Enum.each(&File.rm_rf/1)
  end

  defp mtime(path) do
    case File.stat(path) do
      {:ok, stat} -> stat.mtime
      {:error, _} -> :calendar.universal_time()
    end
  end
end
