defmodule HoneycombRand do

  def getNeighboursForActor(point, degree) do
    point = getCoordinate(point,degree)
    {x,y} = point
    l = []
    l = l ++ [getPoint({x+1,y}, degree)]
    l = l ++ [getPoint({x-1,y}, degree)]
    l = l ++ [:rand.uniform(degree*degree)]
    l = if rem(x+y,2) == 0 do
      l ++ [getPoint({x,y-1}, degree)]
    else
      l ++ [getPoint({x,y+1}, degree)]
    end
    l
    |> Enum.filter(fn(x) -> x > 0 and x <= degree*degree end)
  end

  def getNeighboursForAll(degree) do
    actors = degree*degree
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    map = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, getNeighboursForActor(x, degree))
    end
  end

  def getCoordinate(point, degree) do
    point = point-1
    y = div(point,degree)
    x = rem(point,degree)
    {x,y}
  end

  def getPoint({x,y}, degree) do
    degree*y + x + 1
  end

end
