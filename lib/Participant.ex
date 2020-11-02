defmodule Participant do
  use GenServer

  def start_link(count) do
    GenServer.start_link(__MODULE__, count, [])
  end

  def intialiseNeighbours(participant, neighbours, pidmap, faultyNodes) do
    GenServer.cast(participant, {:intialiseNeighbours, {neighbours, pidmap, faultyNodes}})
  end

  def onMessage(participant, message) do
    GenServer.cast(participant, {:onMessage, {message}})
  end

  def onSW(participant, {s,w}) do
    GenServer.cast(participant, {:onSW, {s,w}})
  end

  # Server APIs
  def init(count) do
    {:ok,
     %{
       :index => count,
       :neighbours => {},
       :pidmap => {},
       :faultyNodes => {},
       :is_transmitting => false,
       :has_converged => false,
       :rumourcount => 0,
       :sw => %{
         :s => count,
         :w => 1
       }
     }}
  end

  def handle_cast(arg1, state) do
    {method, methodArgs} = arg1

    case method do
      :intialiseNeighbours ->
        {neighbours, pidmap, faultyNodes} = methodArgs
        newState = put_in(state.neighbours, neighbours)
        newState = put_in(newState.pidmap, pidmap)
        newState = put_in(newState.faultyNodes, faultyNodes)
        {:noreply, newState}
      :onMessage ->
        {rumour} = methodArgs
        newState = on_message(rumour, state)
        {:noreply, newState}
      :onSW ->
        {s,w} = methodArgs
        newState = on_pushSW({s,w}, state)
        {:noreply, newState}
    end
  end

  def on_pushSW({s,w}, state) do
    newS = (state.sw.s + s) / 2
    newW = (state.sw.w + w) / 2
    newRatios = FourQueue.push(state.sw.ratios, newS / newW)

    newState =
      put_in(state.sw, %{
        :s => newS,
        :w => newW,
        :ratios => newRatios
      })
    diff = FourQueue.diff(newState.sw.ratios)

    newState =
      if diff < :math.pow(10, -10) && state.has_converged == false do
        # IO.puts("#{state.index} has converged")
        Project2.gossipParticipantConverge(:orchestrator)
        put_in(newState.has_converged, true)
      end
      sendSW({state.sw.s,state.sw.w}, state.neighbours, state.pidmap, state.faultyNodes, state.has_converged, state.index)
  end

  def on_message(message, state) do
    newState = put_in(state.rumourcount, state.rumourcount + 1)
    if(newState.rumourcount == 10) do
      put_in(newState.has_converged, true)
      Project2.gossipParticipantConverge(:orchestrator)
    end
    sendMessage(message, state.neighbours, state.pidmap, state.faultyNodes, state.has_converged, state.index)
    newState
  end

  def sendMessage(message, neighbours, pidmap, faultyNodes, has_converged, index) do
    neighbour = Enum.random(neighbours)
    participant = elem(elem(Map.fetch(pidmap,neighbour), 1),1)
    if !has_converged and !(index in faultyNodes) do
      Participant.onMessage(participant, message)
      Process.send_after(self(), {:gossip, message}, 50)
    end
  end

  def sendSW({s,w}, neighbours, pidmap, faultyNodes, has_converged, index) do
    neighbour = Enum.random(neighbours)
    participant = elem(elem(Map.fetch(pidmap,neighbour), 1),1)
    if !has_converged and !(index in faultyNodes) do
      Participant.onSW(participant, {s,w})
      Process.send_after(self(),{:sw,{s,w}}, 50)
    end
  end

  def handle_info(arg1, state) do
    {method, methodArgs} = arg1
    newState = if(state.has_converged == false) do
      case method do
        :gossip ->
          on_message(methodArgs, state)
        :sw ->
          on_pushSW(methodArgs, state)
      end
    end
    {:noreply, newState}
  end

end

defmodule FourQueue do
  def new() do
    [0, 0, 0, 0]
  end

  def push(queue, element) do
    tl(queue) ++ [element]
  end

  def diff(queue) do
    diff = List.first(queue) - List.last(queue)

    cond do
      diff < 0 -> -1 * diff
      true -> diff
    end
  end
end
