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

character_id = "c0a02bd8-2c75-4ea7-bf8a-d0037c1a758a"
character = Characters.get_character!(character_id)
