class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:, id: nil)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_id(id)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new_from_db(info)
  end

  def self.find_by_name(name)
    info = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(info)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      doggy_data = dog[0]
      dog = Dog.new(doggy_data[0], doggy_data[1], doggy_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 






end
