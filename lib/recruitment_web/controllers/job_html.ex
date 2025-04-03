defmodule RecruitmentWeb.JobHTML do
  use RecruitmentWeb, :html

  embed_templates "job_html/*"

  @doc """
  Renders a job form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def job_form(assigns)

  @doc """
  Formats job description text with proper HTML.
  Converts line breaks to <br> tags and handles basic formatting.
  """
  def format_description(nil), do: ""
  def format_description(text) do
    text
    |> String.split("\n")
    |> Enum.map(&Phoenix.HTML.raw(Phoenix.HTML.html_escape(&1)))
    |> Enum.join("<br>")
  end
end
