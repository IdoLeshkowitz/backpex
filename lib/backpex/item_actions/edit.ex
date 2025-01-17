defmodule Backpex.ItemActions.Edit do
  @moduledoc """
  Inline item action to redirect to show view.
  """

  use BackpexWeb, :item_action

  @impl Backpex.ItemAction
  def icon(assigns, _item) do
    ~H"""
    <Backpex.HTML.CoreComponents.icon
      name="hero-pencil-square"
      class="h-5 w-5 cursor-pointer transition duration-75 hover:scale-110 hover:text-blue-600"
    />
    """
  end

  @impl Backpex.ItemAction
  def label(_assigns, _item), do: Backpex.translate("Edit")

  @impl Backpex.ItemAction
  def handle(socket, [item | _items], _data) do
    path = Router.get_path(socket, socket.assigns.live_resource, socket.assigns.params, :edit, item)

    {:ok, Phoenix.LiveView.push_patch(socket, to: path)}
  end
end
