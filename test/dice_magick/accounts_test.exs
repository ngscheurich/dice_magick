defmodule DiceMagick.AccountsTest do
  use DiceMagick.DataCase
  alias DiceMagick.Accounts

  describe "users" do
    alias DiceMagick.Accounts.User

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_discord_uid!/1 returns the user with given discord_uid" do
      user = insert(:user)
      assert Accounts.get_user_by_discord_uid!(user.discord_uid) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =
               Accounts.create_user(%{
                 nickname: "nickname",
                 image: "https://images.io/nickname",
                 discord_uid: "1234567890"
               })

      assert user.nickname == "nickname"
      assert user.image == "https://images.io/nickname"
      assert user.discord_uid == "1234567890"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(%{nickname: nil, discord_uid: nil})
    end

    test "create_user/1 with duplicate discord_uid returns error changeset" do
      insert(:user, discord_uid: "discord0")
      params = params_for(:user, discord_uid: "discord0")

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(params)
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
      user = insert(:user, discord_uid: "discord0")
      auth = %Ueberauth.Auth{uid: "discord0"}
      assert {:ok, ^user} = Accounts.find_or_create_user(auth)
    end
  end
end
