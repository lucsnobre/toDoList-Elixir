defmodule Todo.CLI do
  @moduledoc """
  Command Line Interface for the Todo application.
  Provides an interactive menu for managing tasks.
  """

  alias Todo.{Task, Store}

  @doc """
  Main entry point for the CLI application.
  """
  def main do
    print_welcome()
    
    case Store.load() do
      {:ok, tasks} ->
        next_id = get_next_id(tasks)
        loop(tasks, next_id)
      
      {:error, reason} ->
        IO.puts(IO.ANSI.red() <> "Erro ao carregar tarefas: #{reason}" <> IO.ANSI.reset())
        loop([], 1)
    end
  end

  defp print_welcome do
    IO.puts(IO.ANSI.cyan() <> """
    ╔══════════════════════════════════════╗
    ║           📝 To-Do CLI               ║
    ║      Gerenciador de Tarefas          ║
    ╚══════════════════════════════════════╝
    """ <> IO.ANSI.reset())
  end

  defp loop(tasks, next_id) do
    print_menu()
    
    case get_user_input("Escolha uma opção: ") do
      "1" -> 
        list_tasks(tasks)
        loop(tasks, next_id)
      
      "2" -> 
        new_tasks = add_task(tasks, next_id)
        loop(new_tasks, next_id + 1)
      
      "3" -> 
        new_tasks = mark_task_done(tasks)
        loop(new_tasks, next_id)
      
      "4" -> 
        new_tasks = remove_task(tasks)
        loop(new_tasks, next_id)
      
      "5" -> 
        list_filtered_tasks(tasks)
        loop(tasks, next_id)
      
      "6" -> 
        search_tasks(tasks)
        loop(tasks, next_id)
      
      "7" -> 
        export_tasks(tasks)
        loop(tasks, next_id)
      
      "8" -> 
        backup_tasks()
        loop(tasks, next_id)
      
      "9" -> 
        save_and_exit(tasks)
      
      _ -> 
        IO.puts(IO.ANSI.red() <> "❌ Opção inválida! Tente novamente." <> IO.ANSI.reset())
        loop(tasks, next_id)
    end
  end

  defp print_menu do
    IO.puts(IO.ANSI.yellow() <> """
    
    ═══════════════ MENU ═══════════════
    1. 📋 Listar todas as tarefas
    2. ➕ Adicionar nova tarefa
    3. ✅ Marcar tarefa como concluída
    4. 🗑️  Remover tarefa
    5. 🔍 Filtrar tarefas (pendentes/concluídas)
    6. 🔎 Buscar tarefa por palavra-chave
    7. 📄 Exportar para arquivo .txt
    8. 💾 Criar backup
    9. 🚪 Salvar e sair
    ═══════════════════════════════════
    """ <> IO.ANSI.reset())
  end

  defp list_tasks(tasks) do
    IO.puts(IO.ANSI.cyan() <> "\n📋 LISTA DE TAREFAS:" <> IO.ANSI.reset())
    
    if Enum.empty?(tasks) do
      IO.puts(IO.ANSI.light_black() <> "Nenhuma tarefa cadastrada." <> IO.ANSI.reset())
    else
      tasks
      |> Enum.sort_by(& &1.id)
      |> Enum.each(&IO.puts(Task.to_colored_string(&1)))
      
      print_summary(tasks)
    end
  end

  defp add_task(tasks, next_id) do
    IO.puts(IO.ANSI.green() <> "\n➕ ADICIONAR NOVA TAREFA" <> IO.ANSI.reset())
    
    title = get_user_input("Título da tarefa: ")
    
    if String.trim(title) == "" do
      IO.puts(IO.ANSI.red() <> "❌ Título não pode estar vazio!" <> IO.ANSI.reset())
      tasks
    else
      description = get_user_input("Descrição (opcional): ")
      task = Task.new(next_id, String.trim(title), String.trim(description))
      new_tasks = tasks ++ [task]
      
      case Store.save(new_tasks) do
        {:ok, _} -> 
          IO.puts(IO.ANSI.green() <> "✅ Tarefa adicionada com sucesso!" <> IO.ANSI.reset())
          new_tasks
        
        {:error, reason} -> 
          IO.puts(IO.ANSI.red() <> "❌ Erro ao salvar: #{reason}" <> IO.ANSI.reset())
          tasks
      end
    end
  end

  defp mark_task_done(tasks) do
    if Enum.empty?(tasks) do
      IO.puts(IO.ANSI.yellow() <> "⚠️  Nenhuma tarefa disponível." <> IO.ANSI.reset())
      tasks
    else
      list_tasks(tasks)
      
      case get_task_id("ID da tarefa para marcar como concluída: ") do
        {:ok, id} ->
          case Enum.find(tasks, &(&1.id == id)) do
            nil ->
              IO.puts(IO.ANSI.red() <> "❌ Tarefa não encontrada!" <> IO.ANSI.reset())
              tasks
            
            task ->
              updated_task = Task.mark_done(task)
              new_tasks = Enum.map(tasks, fn t -> if t.id == id, do: updated_task, else: t end)
              
              case Store.save(new_tasks) do
                {:ok, _} -> 
                  IO.puts(IO.ANSI.green() <> "✅ Tarefa marcada como concluída!" <> IO.ANSI.reset())
                  new_tasks
                
                {:error, reason} -> 
                  IO.puts(IO.ANSI.red() <> "❌ Erro ao salvar: #{reason}" <> IO.ANSI.reset())
                  tasks
              end
          end
        
        :error ->
          tasks
      end
    end
  end

  defp remove_task(tasks) do
    if Enum.empty?(tasks) do
      IO.puts(IO.ANSI.yellow() <> "⚠️  Nenhuma tarefa disponível." <> IO.ANSI.reset())
      tasks
    else
      list_tasks(tasks)
      
      case get_task_id("ID da tarefa para remover: ") do
        {:ok, id} ->
          case Enum.find(tasks, &(&1.id == id)) do
            nil ->
              IO.puts(IO.ANSI.red() <> "❌ Tarefa não encontrada!" <> IO.ANSI.reset())
              tasks
            
            _task ->
              new_tasks = Enum.reject(tasks, &(&1.id == id))
              
              case Store.save(new_tasks) do
                {:ok, _} -> 
                  IO.puts(IO.ANSI.green() <> "🗑️  Tarefa removida com sucesso!" <> IO.ANSI.reset())
                  new_tasks
                
                {:error, reason} -> 
                  IO.puts(IO.ANSI.red() <> "❌ Erro ao salvar: #{reason}" <> IO.ANSI.reset())
                  tasks
              end
          end
        
        :error ->
          tasks
      end
    end
  end

  defp list_filtered_tasks(tasks) do
    IO.puts(IO.ANSI.cyan() <> """
    
    🔍 FILTRAR TAREFAS:
    1. Apenas pendentes
    2. Apenas concluídas
    3. Voltar ao menu
    """ <> IO.ANSI.reset())
    
    case get_user_input("Escolha: ") do
      "1" ->
        pending_tasks = Enum.filter(tasks, &(!&1.done))
        IO.puts(IO.ANSI.yellow() <> "\n📋 TAREFAS PENDENTES:" <> IO.ANSI.reset())
        display_filtered_tasks(pending_tasks)
      
      "2" ->
        completed_tasks = Enum.filter(tasks, & &1.done)
        IO.puts(IO.ANSI.green() <> "\n📋 TAREFAS CONCLUÍDAS:" <> IO.ANSI.reset())
        display_filtered_tasks(completed_tasks)
      
      "3" ->
        :ok
      
      _ ->
        IO.puts(IO.ANSI.red() <> "❌ Opção inválida!" <> IO.ANSI.reset())
    end
  end

  defp search_tasks(tasks) do
    keyword = get_user_input("Digite a palavra-chave para buscar: ")
    
    if String.trim(keyword) == "" do
      IO.puts(IO.ANSI.red() <> "❌ Palavra-chave não pode estar vazia!" <> IO.ANSI.reset())
    else
      matching_tasks = Enum.filter(tasks, &Task.matches_keyword?(&1, keyword))
      
      IO.puts(IO.ANSI.cyan() <> "\n🔎 RESULTADOS DA BUSCA para '#{keyword}':" <> IO.ANSI.reset())
      display_filtered_tasks(matching_tasks)
    end
  end

  defp export_tasks(tasks) do
    filename = get_user_input("Nome do arquivo (deixe vazio para 'tasks.txt'): ")
    file = if String.trim(filename) == "", do: "tasks.txt", else: String.trim(filename)
    
    case Store.export_to_txt(tasks, file) do
      {:ok, message} -> 
        IO.puts(IO.ANSI.green() <> "📄 #{message}" <> IO.ANSI.reset())
      
      {:error, reason} -> 
        IO.puts(IO.ANSI.red() <> "❌ #{reason}" <> IO.ANSI.reset())
    end
  end

  defp backup_tasks do
    case Store.backup() do
      {:ok, message} -> 
        IO.puts(IO.ANSI.green() <> "💾 #{message}" <> IO.ANSI.reset())
      
      {:error, reason} -> 
        IO.puts(IO.ANSI.red() <> "❌ #{reason}" <> IO.ANSI.reset())
    end
  end

  defp save_and_exit(tasks) do
    case Store.save(tasks) do
      {:ok, _} -> 
        IO.puts(IO.ANSI.green() <> """
        
        💾 Tarefas salvas com sucesso!
        👋 Até mais! Tenha um ótimo dia!
        """ <> IO.ANSI.reset())
      
      {:error, reason} -> 
        IO.puts(IO.ANSI.red() <> "❌ Erro ao salvar: #{reason}" <> IO.ANSI.reset())
        IO.puts(IO.ANSI.yellow() <> "⚠️  Saindo sem salvar..." <> IO.ANSI.reset())
    end
  end

  # Helper functions

  defp display_filtered_tasks(tasks) do
    if Enum.empty?(tasks) do
      IO.puts(IO.ANSI.light_black() <> "Nenhuma tarefa encontrada." <> IO.ANSI.reset())
    else
      tasks
      |> Enum.sort_by(& &1.id)
      |> Enum.each(&IO.puts(Task.to_colored_string(&1)))
      
      IO.puts(IO.ANSI.light_blue() <> "\nTotal: #{length(tasks)} tarefa(s)" <> IO.ANSI.reset())
    end
  end

  defp print_summary(tasks) do
    total = length(tasks)
    completed = Enum.count(tasks, & &1.done)
    pending = total - completed
    
    IO.puts(IO.ANSI.light_blue() <> """
    
    📊 RESUMO:
    Total: #{total} | Concluídas: #{completed} | Pendentes: #{pending}
    """ <> IO.ANSI.reset())
  end

  defp get_user_input(prompt) do
    IO.gets(IO.ANSI.white() <> prompt <> IO.ANSI.reset())
    |> case do
      :eof -> ""
      input -> String.trim(input)
    end
  end

  defp get_task_id(prompt) do
    case get_user_input(prompt) do
      "" -> 
        :error
      
      input ->
        case Integer.parse(input) do
          {id, ""} -> {:ok, id}
          _ -> 
            IO.puts(IO.ANSI.red() <> "❌ ID inválido! Digite apenas números." <> IO.ANSI.reset())
            :error
        end
    end
  end

  defp get_next_id(tasks) do
    case Enum.max_by(tasks, & &1.id, fn -> %{id: 0} end) do
      %{id: max_id} -> max_id + 1
    end
  end
end
