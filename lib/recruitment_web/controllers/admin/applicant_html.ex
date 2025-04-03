defmodule RecruitmentWeb.Admin.ApplicantHTML do
  use RecruitmentWeb, :html

  embed_templates "applicant_html/*"

  @doc """
  Renders a applicant form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def applicant_form(assigns)
end
