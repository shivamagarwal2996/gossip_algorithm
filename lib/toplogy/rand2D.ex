defmodule Rand2D do

  def getNeighboursForActor(points, actor) do
    point1 = elem(Map.fetch(points, actor), 1)
    actorsList = points
    |> Enum.filter(fn({k, x}) -> getDistance(x, point1) end)
    |> Enum.map(fn({k, x}) -> k  end)
    # Enum.filter_map(
    #   points,                                    # enumerable
    #   fn({k, x}) -> getDistance(x, point1) end,          # filter
    #   fn({k, x}) -> k  end  # mapper
    #   )
    # actorsList = Enum.each(points, fn({k, x}) ->
    #   # IO.puts(x)
    #   if getDistance(point1,x) do
    #     k
    #   end
    # end)
    List.delete(actorsList, actor)
  end

  def getNeighboursForAll(actors) do
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    points = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, getRandomPoint())
    end
    map = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, getNeighboursForActor(points, x))
    end
  end

  def getRandomPoint() do
    x = :rand.uniform(1000)/1000
    y = :rand.uniform(1000)/1000
    {x,y}
  end

  def getDistance(a,b) do
    {x1, y1} = a
    {x2, y2} = b
    dist = (x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)
    if dist < 0.01 do
      true
    end

  end

end
