defmodule TodoCli do
  @moduledoc """
  Main module for the Todo CLI application.
  """

  @doc """
  Entry point for the application.
  """
  def main(args \\ []) do
    case args do
      ["--help"] -> print_help()
      ["--version"] -> print_version()
      _ -> Todo.CLI.main()
    end
  end

  defp print_help do
    IO.puts("""
    Todo CLI - Gerenciador de Tarefas

    USO:
      iex -S mix
      iex> TodoCli.main()

    OU:
      iex> Todo.CLI.main()

    OPÇÕES:
      --help      Mostra esta ajuda
      --version   Mostra a versão

    FUNCIONALIDADES:
      • Adicionar tarefas com título e descrição
      • Listar todas as tarefas
      • Marcar tarefas como concluídas
      • Remover tarefas
      • Filtrar tarefas (pendentes/concluídas)
      • Buscar tarefas por palavra-chave
      • Exportar tarefas para arquivo .txt
      • Criar backup das tarefas
      • Interface colorida e amigável
    """)
  end

  defp print_version do
    IO.puts("Todo CLI v0.1.0")
  end
end
