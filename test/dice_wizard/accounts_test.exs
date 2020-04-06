defmodule DiceWizard.AccountsTest do
  use DiceWizard.DataCase

  alias DiceWizard.Accounts

  describe "users" do
    alias DiceWizard.Accounts.User

    @valid_attrs %{
      nickname: "nickname",
      image: "https://images.io/nickname",
      discord_uid: "1234567890"
    }
    @invalid_attrs %{nickname: nil, discord_uid: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.nickname == "nickname"
      assert user.image == "https://images.io/nickname"
      assert user.discord_uid == "1234567890"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with duplicate discord_uid returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{@valid_attrs | discord_uid: user.discord_uid})
    end

    test "find_or_create_user/1 creates new user" do
      auth = %Ueberauth.Auth{
        uid: "1234567890",
        info: %{nickname: "nickname", image: "https://images.io/nickname"}
      }

      assert {:ok,
              %User{
                nickname: "nickname",
                image: "https://images.io/nickname",
                discord_uid: "1234567890"
              }} = Accounts.find_or_create_user(auth)
    end

    test "find_or_create_user/1 returns existing user" do
      auth = %Ueberauth.Auth{uid: "1234567890"}
      user = user_fixture(%{discord_uid: "1234567890"})
      assert {:ok, ^user} = Accounts.find_or_create_user(auth)
    end
  end
end
