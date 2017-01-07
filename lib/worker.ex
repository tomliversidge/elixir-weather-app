defmodule Tempy.Worker do
  def loop do
    receive do
      {sender_pid, location} -> send(sender_pid, {:ok, temperature_in(location)})
      _ -> IO.puts "unknown message"
    end
    loop
  end

  def temperature_in(location) do
    result = construct_url(location)
      |> HTTPoison.get
      |> parse_response
    case result do
      {:ok, temperature} -> "#{location}: #{temperature} C"
      :error -> "#{location} not found"
    end
  end

  defp construct_url(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{api_key}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp api_key do
    "ac357469057905617e56a65d5acbeeea"
  end
end
