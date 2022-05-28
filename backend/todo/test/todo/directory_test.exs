defmodule Todo.DirectoryTest do
  use Todo.DataCase

  alias Todo.Directory

  describe "todos" do
    alias Todo.Directory.TodoItem

    import Todo.DirectoryFixtures

    @invalid_attrs %{detail: nil, title: nil}

    test "list_todos/0 returns all todos" do
      todo_item = todo_item_fixture()
      assert Directory.list_todos() == [todo_item]
    end

    test "get_todo_item!/1 returns the todo_item with given id" do
      todo_item = todo_item_fixture()
      assert Directory.get_todo_item!(todo_item.id) == todo_item
    end

    test "create_todo_item/1 with valid data creates a todo_item" do
      valid_attrs = %{detail: "some detail", title: "some title"}

      assert {:ok, %TodoItem{} = todo_item} = Directory.create_todo_item(valid_attrs)
      assert todo_item.detail == "some detail"
      assert todo_item.title == "some title"
    end

    test "create_todo_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Directory.create_todo_item(@invalid_attrs)
    end

    test "update_todo_item/2 with valid data updates the todo_item" do
      todo_item = todo_item_fixture()
      update_attrs = %{detail: "some updated detail", title: "some updated title"}

      assert {:ok, %TodoItem{} = todo_item} = Directory.update_todo_item(todo_item, update_attrs)
      assert todo_item.detail == "some updated detail"
      assert todo_item.title == "some updated title"
    end

    test "update_todo_item/2 with invalid data returns error changeset" do
      todo_item = todo_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Directory.update_todo_item(todo_item, @invalid_attrs)
      assert todo_item == Directory.get_todo_item!(todo_item.id)
    end

    test "delete_todo_item/1 deletes the todo_item" do
      todo_item = todo_item_fixture()
      assert {:ok, %TodoItem{}} = Directory.delete_todo_item(todo_item)
      assert_raise Ecto.NoResultsError, fn -> Directory.get_todo_item!(todo_item.id) end
    end

    test "change_todo_item/1 returns a todo_item changeset" do
      todo_item = todo_item_fixture()
      assert %Ecto.Changeset{} = Directory.change_todo_item(todo_item)
    end
  end
end
