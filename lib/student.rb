require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :id, :grade;

  def initialize (id:nil ,name:, grade:) 
    @id =id
    @name=name
    @grade =grade

  end

  
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end
 
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students 
    SQL

    DB[:conn].execute(sql)
  end
 
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      self
    end
  end

  def self.create
    student = Student.new(name,grade)
    student.save
  end
  
  def self.new_from_db(row)
     self.new(id: row[0], name: row[1], grade: row[2])
  end
 
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL
    
    DB[:conn].execute(sql ,name).map do |row|
      self.new_from_db
    end.first
  end

  def update
    sql = "UPDATE songs SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
