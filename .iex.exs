alias Repo
alias Accounts
alias Characters
alias Rolls
alias Taxonomy
alias Source
alias Accounts.{User}
alias Characters.{Character}
alias Rolls.{Roll, Encoder, CSVEncoder}
alias Taxonomy.{Tag, RollTag}
alias Sources.{GoogleSheets, Test, Source}

sheet_id = "1sEEi3cUfUqc-suoKGPhMQ0eh7KCPbn3ksgOZ-b5q3QI"
character = Characters.get_character!("c6ec9032-5278-48fa-9f1c-ecbec626b9fc")
{:ok, pid} = Characters.Process.start_link(character.id)

# [todo]
# - [ ] Should rolls/tags even be stored in the database (or use the source as the permanent copy?)
#   - If we don't store them in the database, we lose access to certain roll metrics
#   - We could just store the raw data retrieved from the source?
#   - If we don't store rolls in the DB, we lose access to DB constraints
# - [ ] Rolls should be identified by name, and updated/created based on that
#   - Again, if we just replace roll wholesale on update, we might lose some metrics
# - [ ] Don't throw away roll when the name doesn't match
#   - Otherwise, a simple typo in a data source could destroy a lot of historical data
