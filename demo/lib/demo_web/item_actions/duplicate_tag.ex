defmodule DemoWeb.ItemActions.DuplicateTag do
  @moduledoc false

  use BackpexWeb, :item_action

  alias Demo.Repo

  @impl Backpex.ItemAction
  def icon(assigns, _item) do
    ~H"""
    <Backpex.HTML.CoreComponents.icon
      name="hero-document-duplicate"
      class="h-5 w-5 cursor-pointer transition duration-75 hover:scale-110 hover:text-green-600"
    />
    """
  end

  @impl Backpex.ItemAction
  def fields do
    [
      name: %{
        module: Backpex.Fields.Text,
        label: "Name",
        searchable: true,
        placeholder: "Tag name"
      }
    ]
  end

  @impl Backpex.ItemAction
  def label(_assigns, nil), do: "Duplicate"
  def label(_assigns, item), do: "Duplicate #{item.name}"

  @impl Backpex.ItemAction
  def confirm(_assigns), do: "Please complete the form to duplicate the item."

  @impl Backpex.ItemAction
  def confirm_label(_assigns), do: "Duplicate"

  @impl Backpex.ItemAction
  def cancel_label(_assigns), do: "Cancel"

  @impl Backpex.ItemAction
  def changeset(item, change, metadata) do
    Demo.Tag.create_changeset(item, change, metadata)
  end

  @impl Backpex.ItemAction
  def base_schema(assigns) do
    [item | _other] = assigns.selected_items

    item
  end

  @impl Backpex.ItemAction
  def handle(socket, _items, data) do
    params = Map.from_struct(data)

    result =
      %Demo.Tag{}
      |> Demo.Tag.create_changeset(params, target: nil, assigns: socket.assigns)
      |> Repo.insert()

    socket =
      case result do
        {:ok, _created} ->
          put_flash(socket, :info, "Item has been duplicated.")

        _error ->
          put_flash(socket, :error, "Error while duplicating item.")
      end

    {:ok, socket}
  end
end
