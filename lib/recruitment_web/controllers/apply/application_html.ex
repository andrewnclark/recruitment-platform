defmodule RecruitmentWeb.Apply.ApplicationHTML do
  use RecruitmentWeb, :html

  embed_templates "application_html/*"

  @doc """
  Renders a application form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def application_form(assigns)
  
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
