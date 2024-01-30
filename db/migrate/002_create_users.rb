Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, unique: true
      String :crypted_password
    end
  end
end
