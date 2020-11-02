defmodule Full do

  def getNeighboursForActor(actors, actor) do
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    List.delete_at(actorsList, actor-1)
  end

  def getNeighboursForAll(actors) do
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    map = Enum.reduce actorsList, %{}, fn x, acc ->
      Map.put(acc, x, getNeighboursForActor(actors, x))
  end
  end
end
