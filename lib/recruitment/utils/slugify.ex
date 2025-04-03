defmodule Slugify do
  @moduledoc """
  Utility module for generating URL-friendly slugs from strings.
  """

  @doc """
  Converts a string into a URL-friendly slug.

  ## Examples

      iex> Slugify.slugify("Hello World")
      "hello-world"

      iex> Slugify.slugify("Special Characters: !@#$%^&*()")
      "special-characters"

  """
  def slugify(string) when is_binary(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
    |> ensure_unique_suffix()
  end

  def slugify(_), do: ""

  @doc """
  Adds a random suffix to ensure uniqueness if needed.
  This is a placeholder - the actual implementation in the Job schema
  handles the uniqueness check against the database.
  """
  def ensure_unique_suffix(slug) do
    slug
  end

  @doc """
  Generates a random suffix for slugs when needed to ensure uniqueness.
  """
  def random_suffix(length \\ 6) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode16(case: :lower)
    |> binary_part(0, length)
  end
end
