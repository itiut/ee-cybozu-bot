Sequel.migration do
  up do
    self[:groups].insert(name: '全体')
    self[:groups].insert(name: '学部学生')
    self[:groups].insert(name: '全大学院生')
  end

  down do
    self[:groups].delete
  end
end
