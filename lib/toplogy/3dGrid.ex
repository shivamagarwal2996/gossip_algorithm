defmodule Grid do

  def getNeighboursForActor(point, degree) do
    point = getCoordinate(point,degree)
    {x,y,z} = point
    l = []
    l = l ++ [getPoint({x+1,y,z}, degree)]
    l = l ++ [getPoint({x-1,y,z}, degree)]
    l = l ++ [getPoint({x,y+1,z}, degree)]
    l = l ++ [getPoint({x,y-1,z}, degree)]
    l = l ++ [getPoint({x,y,z+1}, degree)]
    l = l ++ [getPoint({x,y,z-1}, degree)]

  end

  def getNeighboursForAll(degree) do
    actors = degree*degree*degree
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    map = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, getNeighboursForActor(x, degree))
    end
  end

  def getCoordinate(point, degree) do
    point = point-1
    z = div(point,degree*degree)
    xy = rem(point,degree*degree)
    y = div(xy,degree)
    x = rem(xy,degree)
    {x,y,z}
  end

  def getPoint({x,y,z}, degree) do
    x = if x == -1 do
      x = degree-1
    else
      x
    end
    y = if y == -1 do
      y = degree-1
    else
      y
    end

    z = if z == -1 do
      z = degree-1
    else
      z
    end
    x = if x == degree do
      x = 0
    else
      x
    end
    y = if y == degree do
      y = 0
    else
      y
    end
    z = if z == degree do
      z = 0
    else
      z
    end
    degree*degree*z + degree*y + x + 1
  end
end
