defmodule Backpex.ItemAction do
  @moduledoc """
  Behaviour implemented by all item actions.
  """

  @doc """
  Action icon
  """
  @callback icon(assigns :: map(), item :: struct()) :: %Phoenix.LiveView.Rendered{}

  @doc """
  A list of fields to be displayed in the item action. See `Backpex.Field`. In addition you have to provide
  a `type` for each field in order to support changeset generation.

  The following fields are currently not supported:

  - `Backpex.Fields.BelongsTo`
  - `Backpex.Fields.HasMany`
  - `Backpex.Fields.HasManyThrough`
  - `Backpex.Fields.Upload`
  """
  @callback fields() :: list()

  @doc """
  TODO: rename to `init_schema`

  Initial change. The result will be passed to `c:changeset/3` in order to generate a changeset.

  This function is optional and can be used to use changesets with schemas in item actions. If this function
  is not provided a changeset will be generated automatically based on the provided types in `c:fields/0`.
  """
  @callback init_change(assigns :: map()) ::
              Ecto.Schema.t()
              | Ecto.Changeset.t()
              | {Ecto.Changeset.data(), Ecto.Changeset.types()}

  @doc """
  The changeset to be used in the resource action. It may be used to validate form inputs.

  Additional metadata is passed as a keyword list via the third parameter.

  The list of metadata:
  - `:assigns` - the assigns
  - `:target` - the name of the `form` target that triggered the changeset call. Default to `nil` if the call was not triggered by a form field.
  """
  @callback changeset(
              change ::
                Ecto.Schema.t()
                | Ecto.Changeset.t()
                | {Ecto.Changeset.data(), Ecto.Changeset.types()},
              attrs :: map(),
              metadata :: keyword()
            ) :: Ecto.Changeset.t()

  @doc """
  Action label (Show label on hover)
  """
  @callback label(assigns :: map(), item :: struct() | nil) :: binary()

  @doc """
  Confirm button label
  """
  @callback confirm_label(assigns :: map()) :: binary()

  @doc """
  cancel button label
  """
  @callback cancel_label(assigns :: map()) :: binary()

  @doc """
  This text is being displayed in the confirm dialog.

  There won't be any confirmation when this function is not defined.
  """
  @callback confirm(assigns :: map()) :: binary()

  @doc """
  Performs the action. It takes the socket and the casted and validated data (received from [`Ecto.Changeset.apply_action/2`](https://hexdocs.pm/ecto/Ecto.Changeset.html#apply_action/2)).
  """
  @callback handle(socket :: Phoenix.LiveView.Socket.t(), items :: list(map()), params :: map() | struct()) ::
              {:noreply, Phoenix.LiveView.Socket.t()} | {:reply, map(), Phoenix.LiveView.Socket.t()}

  @optional_callbacks confirm: 1, confirm_label: 1, cancel_label: 1, changeset: 3, fields: 0

  @doc """
  Defines `Backpex.ItemAction` behaviour and provides default implementations.
  """
  defmacro __using__(_) do
    quote do
      @before_compile Backpex.ItemAction
      @behaviour Backpex.ItemAction
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @impl Backpex.ItemAction
      def confirm_label(_assigns), do: Backpex.translate("Apply")

      @impl Backpex.ItemAction
      def cancel_label(_assigns), do: Backpex.translate("Cancel")

      @impl Backpex.ItemAction
      def fields, do: []

      @impl Backpex.ItemAction
      def changeset(_change, _attrs, metadata) do
        assigns = Keyword.get(metadata, :assigns)

        init_change(assigns)
        |> Ecto.Changeset.change()
      end

      @impl Backpex.ItemAction
      def init_change(_assigns) do
        types = fields() |> Backpex.Field.changeset_types()

        {%{}, types}
      end
    end
  end

  @doc """
  Checks whether item action has confirmation modal.
  """
  def has_confirm_modal?(item_action) do
    module = Map.fetch!(item_action, :module)

    function_exported?(module, :confirm, 1)
  end

  @doc """
  Checks whether item action has form.
  """
  def has_form?(item_action) do
    module = Map.fetch!(item_action, :module)

    module.fields() != []
  end
end
