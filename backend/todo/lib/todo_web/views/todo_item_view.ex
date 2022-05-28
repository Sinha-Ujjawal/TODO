defmodule TodoWeb.TodoItemView do
  use TodoWeb, :view
  alias TodoWeb.TodoItemView

  def render("index.json", %{todos: todos}) do
    %{data: render_many(todos, TodoItemView, "todo_item.json")}
  end

  def render("show.json", %{todo_item: todo_item}) do
    %{data: render_one(todo_item, TodoItemView, "todo_item.json")}
  end

  def render("todo_item.json", %{todo_item: todo_item}) do
    %{
      id: todo_item.id,
      title: todo_item.title,
      detail: todo_item.detail
    }
  end
end
