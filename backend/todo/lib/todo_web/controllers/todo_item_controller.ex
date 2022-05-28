defmodule TodoWeb.TodoItemController do
  use TodoWeb, :controller

  alias Todo.Directory
  alias Todo.Directory.TodoItem

  action_fallback TodoWeb.FallbackController

  def index(conn, _params) do
    todos = Directory.list_todos()
    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo_item" => todo_item_params}) do
    with {:ok, %TodoItem{} = todo_item} <- Directory.create_todo_item(todo_item_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.todo_item_path(conn, :show, todo_item))
      |> render("show.json", todo_item: todo_item)
    end
  end

  def show(conn, %{"id" => id}) do
    todo_item = Directory.get_todo_item!(id)
    render(conn, "show.json", todo_item: todo_item)
  end

  def update(conn, %{"id" => id, "todo_item" => todo_item_params}) do
    todo_item = Directory.get_todo_item!(id)

    with {:ok, %TodoItem{} = todo_item} <- Directory.update_todo_item(todo_item, todo_item_params) do
      render(conn, "show.json", todo_item: todo_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo_item = Directory.get_todo_item!(id)

    with {:ok, %TodoItem{}} <- Directory.delete_todo_item(todo_item) do
      send_resp(conn, :no_content, "")
    end
  end
end
