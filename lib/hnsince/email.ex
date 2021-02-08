defmodule HNSince.Email do
  alias HNSince.Email
  alias HNSince.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :email, :string
    field :session_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:session_id, :email])
    |> validate_required([:session_id, :email])
  end

  def insert(email, session_id) do
    Email.changeset(%Email{}, %{session_id: session_id, email: email})
    |> Repo.insert()
    |> IO.inspect(label: "Insert")
  end
end
