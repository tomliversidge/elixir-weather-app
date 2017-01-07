defmodule Tempy do
  def temperature_in(cities) do
    coordinator_pid = spawn(Tempy.Coordinator, :loop, [[], Enum.count(cities)])
    cities |> Enum.each(fn city ->
      worker_pid = spawn(Tempy.Worker, :loop, [])
      send worker_pid, {coordinator_pid, city}
    end)
  end
end
