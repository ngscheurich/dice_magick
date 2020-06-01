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

Logger.configure(level: :info)
