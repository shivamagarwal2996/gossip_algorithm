defmodule Project2 do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def generateParticipants(server, numNodes, topology, fault) do
    GenServer.call(server, {:generateParticipants, {numNodes, topology, fault}})

  end

  def gossipParticipantConverge(server) do
    GenServer.cast(server, {:gossipParticipantConverge, {1}})
  end

  def startRumour(server, rumour) do
    GenServer.cast(server, {:startRumour, {rumour}})
  end

  def startSW(server) do
    GenServer.cast(server, {:startSW, {}})
  end

  ## Server Callbacks
  def init(:ok) do
    {:ok,
     %{
       :start_time => nil,
       :nodes => 0,
       :pidmap => nil,
       :gossip_convergence => 0,
       :ps_convergence => 0
     }}
  end

  def start(_type, _args) do

  end

  def handle_cast({method, methodArgs}, state) do
    case method do
      :startRumour ->
        {rumour} = methodArgs
        newState = handleStartRumour(rumour, state)
        {:noreply, newState}

      :startSW ->
        newState = handleStartSW(state)
        {:noreply, newState}

      :gossipParticipantConverge ->
        newState = handleGossipParticipantConverge(state)
        {:noreply, newState}

      :finish ->
        handleFinish(state)
        {:noreply, state}
    end
  end

  def handle_call({:generateParticipants, methodArgs}, _, state) do
    {numNodes, topology, fault} = methodArgs
    ret_val = generateParticipants1(numNodes, topology, state, fault)
    {:reply, :ok, Map.merge(state, ret_val)}
  end

  def generateParticipants1(actors, topology, state, fault) do
    degree =
      case topology do
        "3Dtorus" -> :math.ceil(:math.pow(actors, 0.33)) |> Kernel.trunc()
        "honeycomb" -> :math.ceil(:math.pow(actors, 0.5)) |> Kernel.trunc()
        "randhoneycomb" -> :math.ceil(:math.pow(actors, 0.5)) |> Kernel.trunc()
      _   -> actors
    end
    actors =
      case topology do
        "3Dtorus" -> :math.pow(degree, 3) |> Kernel.trunc()
        "honeycomb" -> :math.pow(degree, 2) |> Kernel.trunc()
        "randhoneycomb" -> :math.pow(degree, 2) |> Kernel.trunc()
      _   -> actors
    end
    actorsList = Enum.map(1..actors, fn (x) -> x end)
    pidmap = Enum.reduce actorsList, %{}, fn x, acc ->
    Map.put(acc, x, Participant.start_link(x))
    end
    neighbours =
      case topology do
        "line" -> Line.getNeighboursForAll(actors)
        "full" -> Full.getNeighboursForAll(actors)
        "3Dtorus" -> Grid.getNeighboursForAll(degree)
        "rand2D" -> Rand2D.getNeighboursForAll(actors)
        "honeycomb" -> Honeycomb.getNeighboursForAll(degree)
        "randhoneycomb" -> HoneycombRand.getNeighboursForAll(degree)
        _ -> raise("Invalid Topology")
      end
    faultyNodes = Random.getList(fault, actors)
    Enum.each(pidmap, fn({k, x}) ->
    neighbour = elem(Map.fetch(neighbours,k),1)
    participant = elem(elem(Map.fetch(pidmap,k), 1),1)
    Participant.intialiseNeighbours(participant, neighbour, pidmap, faultyNodes)
    end)
    %{:nodes => actors, :pidmap => pidmap}
  end

  def handleGossipParticipantConverge(state) do
    newState = put_in(state.gossip_convergence, state.gossip_convergence + 1)
    IO.puts("Total nodes converged = #{newState.gossip_convergence}/#{newState.nodes}")

    if((newState.gossip_convergence > 0.7 * newState.nodes)) do
      IO.puts("Total nodes converged = #{newState.gossip_convergence}/#{newState.nodes}")
      handleFinish(newState)
    end
    newState
  end

  def handleStartRumour(rumour, state) do
    start_time = Time.utc_now()
    participant = elem(elem(Map.fetch(state.pidmap,1), 1),1)
    Participant.onMessage(participant, rumour)
    put_in(state.start_time, start_time)
  end

  def handleStartSW(state) do
    start_time = Time.utc_now()
    participant = elem(elem(Map.fetch(state.pidmap,1), 1),1)
    Participant.onMessage(participant, {0,0})
    put_in(state.start_time, start_time)
  end

  def handleFinish(state) do
    end_time = Time.utc_now()
    IO.write("Finished. Time taken: ")
    IO.inspect(Time.diff(end_time, state.start_time, :microsecond) / 1_000_000)
    state.pidmap |> Enum.map(fn {_, {_,v}} -> Process.exit(v, "Voluntary Termination") end)
    IO.write("Killed")
    send(:daemon, {:result, state})
  end
end

defmodule Sample do

  def start(_type, _args) do
    # Receiving command line arguments
    l = System.argv()

    {numNodes, ""} = Integer.parse(Enum.at(l, 0))

    {fault, ""} = if length(l) == 4 do
      Integer.parse(Enum.at(l, 3))
    else
      {0,""}
    end
    topology = Enum.at(l, 1)
    algorithm = Enum.at(l, 2)

    {:ok, orchestrator_pid} = Project2.start_link([])
    Process.register(orchestrator_pid, :orchestrator)
    Project2.generateParticipants(:orchestrator, numNodes, topology, fault)
    case algorithm do
      "gossip" -> Project2.startRumour(:orchestrator, "Hello World")
      "push-sum" -> Project2.startSW(:orchestrator)
    end
    receive do
      {:result, result} ->
        IO.puts("end")
        IO.puts(result)
    end
  end
end

defmodule Random do
  def getList(fault, actors) do
    size = fault*actors/100 |> Kernel.trunc()
    1..size |> Enum.map(fn _ -> Enum.random(1..actors) end)
  end
end
