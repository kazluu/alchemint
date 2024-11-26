defmodule Alchemint.Repo do
  use Ecto.Repo,
    otp_app: :alchemint,
    adapter: Ecto.Adapters.Postgres
end
