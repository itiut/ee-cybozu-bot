Sequel.migration do
  up do
    create_table(:groups) do
      Integer :id, primary_key: true
      String :name
    end

    create_table(:notices) do
      Integer :id, primary_key: true
      foreign_key :group_id, :groups
      String :title
      String :content
      Time :issued_time
    end

    create_table(:tweet_queues) do
      primary_key :id
      foreign_key :notice_id, :notices
    end
  end

  down do
    drop_table(:tweet_queues)
    drop_table(:notices)
    drop_table(:groups)
  end
end
