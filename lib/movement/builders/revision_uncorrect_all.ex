defmodule Movement.Builders.RevisionUncorrectAll do
  @behaviour Movement.Builder

  import Movement.Context, only: [assign: 3]

  alias Movement.Mappers.Operation, as: OperationMapper
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.{Repo, Translation}

  @action "uncorrect_conflict"

  def build(context) do
    context
    |> assign_translations
    |> process_operations
  end

  defp process_operations(context = %Movement.Context{assigns: assigns, operations: operations}) do
    new_operations =
      Enum.map(assigns[:translations], fn translation ->
        OperationMapper.map(@action, translation, %{text: nil})
      end)

    %{context | operations: Enum.concat(operations, new_operations)}
  end

  defp assign_translations(context = %Movement.Context{assigns: assigns}) do
    translations =
      Translation
      |> TranslationScope.active()
      |> TranslationScope.not_locked()
      |> TranslationScope.not_conflicted()
      |> TranslationScope.from_revision(assigns[:revision].id)
      |> Repo.all()

    assign(context, :translations, translations)
  end
end
