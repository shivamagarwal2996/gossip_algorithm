defmodule Line do

  def getNeighboursForActor(actors, actor) do
    cond do
      actor == 1 ->
        [2]
      actor == actors ->
        [actor-1]
      true ->
        prev = actor-1
        post = actor+1
        [prev,post]
    end
  end

  def getNeighboursForAll(actors) do
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    map = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, getNeighboursForActor(actors, x))
    end
  end
end
