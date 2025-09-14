defmodule Todo.Task do
  @moduledoc """
  Defines the Task struct and related functions for managing todo items.
  """

  defstruct [:id, :title, :description, :done, :created_at]

  @doc """
  Creates a new task with the given id, title, and optional description.
  """
  def new(id, title, description \\ "") do
    %__MODULE__{
      id: id,
      title: title,
      description: description,
      done: false,
      created_at: DateTime.utc_now() |> DateTime.to_iso8601()
    }
  end

  @doc """
  Marks a task as completed.
  """
  def mark_done(task) do
    %{task | done: true}
  end

  @doc """
  Marks a task as pending (undone).
  """
  def mark_pending(task) do
    %{task | done: false}
  end

  @doc """
  Updates the title of a task.
  """
  def update_title(task, new_title) do
    %{task | title: new_title}
  end

  @doc """
  Updates the description of a task.
  """
  def update_description(task, new_description) do
    %{task | description: new_description}
  end

  @doc """
  Checks if a task matches a search keyword (case-insensitive).
  """
  def matches_keyword?(task, keyword) do
    keyword_lower = String.downcase(keyword)
    
    String.contains?(String.downcase(task.title), keyword_lower) ||
    String.contains?(String.downcase(task.description), keyword_lower)
  end

  @doc """
  Returns a formatted string representation of the task.
  """
  def to_string(task) do
    status = if task.done, do: "[✔]", else: "[ ]"
    description = if task.description != "", do: " - #{task.description}", else: ""
    "#{task.id}. #{status} #{task.title}#{description}"
  end

  @doc """
  Returns a colored string representation of the task using IO.ANSI.
  """
  def to_colored_string(task) do
    status = if task.done, do: IO.ANSI.green() <> "[✔]", else: IO.ANSI.yellow() <> "[ ]"
    title = if task.done, do: IO.ANSI.light_black() <> task.title, else: IO.ANSI.white() <> task.title
    description = if task.description != "", do: IO.ANSI.light_blue() <> " - #{task.description}", else: ""
    reset = IO.ANSI.reset()
    
    "#{IO.ANSI.cyan()}#{task.id}.#{reset} #{status}#{reset} #{title}#{description}#{reset}"
  end
end
