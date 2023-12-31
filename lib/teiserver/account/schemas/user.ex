defmodule Teiserver.Account.User do
  @moduledoc false
  use TeiserverMacros, :schema
  alias Argon2

  schema "account_users" do
    field(:name, :string)
    field(:email, :string)
    field(:password, :string)

    field(:roles, {:array, :string}, default: [])
    field(:permissions, {:array, :string}, default: [])

    field(:behaviour_score, :integer)
    field(:trust_score, :integer)
    field(:social_score, :integer)

    field(:last_login_at, :utc_datetime)
    field(:last_played_at, :utc_datetime)
    field(:last_logout_at, :utc_datetime)

    field(:restrictions, {:array, :string}, default: [])
    field(:restricted_until, :utc_datetime)

    field(:shadow_banned, :boolean, default: false)

    # Extra user.ex relations go here
    belongs_to(:smurf_of, Teiserver.Account.User)

    has_one(:extra_data, Teiserver.Account.ExtraUserData)

    timestamps()
  end

  @doc false
  def changeset(user), do: changeset(user, %{}, :full)

  def changeset(user, attrs, :full) do
    attrs =
      attrs
      |> SchemaHelper.trim_strings([:email])
      |> SchemaHelper.uniq_lists(~w(permissions roles)a)

    # If password isn't included we won't be doing anything with it
    if attrs["password"] == "" do
      user
      |> cast(
        attrs,
        ~w(name email roles permissions behaviour_score trust_score social_score last_login_at last_played_at last_logout_at restrictions restricted_until shadow_banned smurf_of_id)a
      )
      |> validate_required(~w(name email permissions)a)
      |> unique_constraint(:email)
    else
      user
      |> cast(
        attrs,
        ~w(name email password roles permissions behaviour_score trust_score social_score last_login_at last_played_at last_logout_at restrictions restricted_until shadow_banned smurf_of_id)a
      )
      |> validate_required(~w(name email permissions)a)
      |> unique_constraint(:email)
      |> put_password_hash()
    end
  end

  def changeset(struct, permissions, :permissions) do
    cast(struct, %{permissions: Enum.uniq(permissions)}, [:permissions])
  end

  def changeset(user, attrs, :profile) do
    attrs =
      attrs
      |> SchemaHelper.trim_strings([:email])

    user
    |> cast(attrs, ~w(name email)a)
    |> validate_required(~w(name email)a)
    |> unique_constraint(:email)
  end

  def changeset(user, attrs, :user_form) do
    attrs =
      attrs
      |> SchemaHelper.trim_strings([:email])

    cond do
      attrs["password"] == nil or attrs["password"] == "" ->
        user
        |> cast(attrs, [:name, :email])
        |> validate_required([:name, :email])
        |> add_error(
          :password_confirmation,
          "Please enter your password to change your account details."
        )

      verify_password(attrs["password"], user.password) == false ->
        user
        |> cast(attrs, [:name, :email])
        |> validate_required([:name, :email])
        |> add_error(:password_confirmation, "Incorrect password")

      true ->
        user
        |> cast(attrs, [:name, :email])
        |> validate_required([:name, :email])
        |> unique_constraint(:email)
    end
  end

  # They are logged in and want to change their password
  # we ask for the existing password to be submitted as a test
  # they have not left the computer unlocked or similar
  def changeset(user, attrs, :change_password) do
    cond do
      attrs["existing"] == nil or attrs["existing"] == "" ->
        user
        |> change_password(attrs)
        |> add_error(
          :password_confirmation,
          "Please enter your existing password to change your password."
        )

      verify_password(attrs["existing"], user.password) == false ->
        user
        |> change_password(attrs)
        |> add_error(:existing, "Incorrect password")

      true ->
        user
        |> change_password(attrs)
    end
  end

  # For when they don't know their password and you have verified their identity some other way
  def changeset(user, attrs, :forgot_password) do
    user
    |> change_password(attrs)
  end

  defp change_password(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password, message: "Does not match password")
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  @spec verify_password(User.t(), String.t()) :: boolean
  def verify_password(plain_text_password, encrypted) do
    Argon2.verify_pass(plain_text_password, encrypted)
  end
end
