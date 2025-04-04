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
    # First escape the text, then convert newlines to <br> tags
    escaped = Phoenix.HTML.html_escape(text)
    
    # Return the content as a string instead of a safe tuple
    escaped
    |> Phoenix.HTML.safe_to_string()
    |> String.split("\n")
    |> Enum.join("<br>")
  end
end
