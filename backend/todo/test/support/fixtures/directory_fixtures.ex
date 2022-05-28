defmodule Todo.DirectoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Todo.Directory` context.
  """

  @doc """
  Generate a todo_item.
  """
  def todo_item_fixture(attrs \\ %{}) do
    {:ok, todo_item} =
      attrs
      |> Enum.into(%{
        detail: "some detail",
        title: "some title"
      })
      |> Todo.Directory.create_todo_item()

    todo_item
  end
end
