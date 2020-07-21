defmodule Training.Util.Graphviz do
  require Logger

  @graphviz_executable "dot"

  def image(string, format \\ "png") do
    case image_data(string, format) do
      {:ok, data} ->
        base64_encoded_image = Base.encode64(data)

        ["<img src=\"data:image/", format, ";base64,", base64_encoded_image, "\"/>"]

      {:error, reason} ->
        "_Broken image (reason: #{inspect(reason)})_"
    end
  end

  def image_data(string, format) do
    case System.find_executable(@graphviz_executable) do
      nil ->
        Logger.warn(
          "could not find graphviz executable (#{@graphviz_executable}) in $PATH. Unable to render state machine as image."
        )

        {:error, :no_executable}

      dot_exec ->
        port = Port.open({:spawn_executable, dot_exec}, [:binary, args: ["-T#{format}"]])

        Port.command(port, string)

        binary_image_data =
          receive do
            {^port, {:data, data}} -> data
          end

        Port.close(port)
        {:ok, binary_image_data}
    end
  end
end
