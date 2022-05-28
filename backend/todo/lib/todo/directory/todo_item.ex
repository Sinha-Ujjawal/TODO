defmodule Todo.Directory.TodoItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :detail, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(todo_item, attrs) do
    todo_item
    |> cast(attrs, [:title, :detail])
    |> validate_required([:title, :detail])
  end
end
