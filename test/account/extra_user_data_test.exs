defmodule Account.ExtraUserDataTest do
  @moduledoc false
  use Teiserver.Case, async: true

  alias Teiserver.AccountFixtures
  alias Teiserver.Account.ExtraUserData

  describe "ExtraUserData" do
    test "changesets" do
      user = AccountFixtures.extra_user_data_fixture()
      c = ExtraUserData.changeset(user)
      assert %Ecto.Changeset{} = c
    end
  end
end
