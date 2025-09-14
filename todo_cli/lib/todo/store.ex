defmodule Todo.Store do
  @moduledoc """
  Handles persistence of tasks to and from JSON files.
  """

  alias Todo.Task

  @default_file "tasks.json"

  @doc """
  Saves a list of tasks to a JSON file.
  """
  def save(tasks, file \\ @default_file) do
    try do
      tasks
      |> Enum.map(&task_to_map/1)
      |> Jason.encode!(pretty: true)
      |> then(&File.write!(file, &1))
      
      {:ok, "Tasks saved successfully to #{file}"}
    rescue
      error ->
        {:error, "Failed to save tasks: #{Exception.message(error)}"}
    end
  end

  @doc """
  Loads tasks from a JSON file.
  """
  def load(file \\ @default_file) do
    case File.read(file) do
      {:ok, content} ->
        try do
          content
          |> Jason.decode!()
          |> Enum.map(&map_to_task/1)
          |> then(&{:ok, &1})
        rescue
          error ->
            {:error, "Failed to parse JSON: #{Exception.message(error)}"}
        end
      
      {:error, :enoent} ->
        {:ok, []}
      
      {:error, reason} ->
        {:error, "Failed to read file: #{reason}"}
    end
  end

  @doc """
  Exports tasks to a plain text file.
  """
  def export_to_txt(tasks, file \\ "tasks.txt") do
    try do
      content = 
        tasks
        |> Enum.map(&Task.to_string/1)
        |> Enum.join("\n")
      
      File.write!(file, content)
      {:ok, "Tasks exported successfully to #{file}"}
    rescue
      error ->
        {:error, "Failed to export tasks: #{Exception.message(error)}"}
    end
  end

  @doc """
  Creates a backup of the current tasks file.
  """
  def backup(file \\ @default_file) do
    backup_file = "#{file}.backup.#{DateTime.utc_now() |> DateTime.to_unix()}"
    
    case File.copy(file, backup_file) do
      {:ok, _} -> {:ok, "Backup created: #{backup_file}"}
      {:error, reason} -> {:error, "Failed to create backup: #{reason}"}
    end
  end

  @doc """
  Returns the default file path.
  """
  def default_file, do: @default_file

  # Private functions

  defp task_to_map(%Task{} = task) do
    %{
      "id" => task.id,
      "title" => task.title,
      "description" => task.description,
      "done" => task.done,
      "created_at" => task.created_at
    }
  end

  defp task_to_map(task) when is_map(task) do
    # Handle case where task is already a map (for backwards compatibility)
    task
  end

  defp map_to_task(map) when is_map(map) do
    %Task{
      id: map["id"],
      title: map["title"],
      description: map["description"] || "",
      done: map["done"] || false,
      created_at: map["created_at"]
    }
  end
end
