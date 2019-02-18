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









end
