require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    #access database connection via DB[:conn]
    DB[:conn].execute(sql) 
  end
  
  # Drops students table in the database
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end
  
  # Saves an instance of the Student class to the database and then
  # sets the given students `id` attribute
  def save
    # Updates record if called on an obj that's already persisted
    if self.id 
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end  
    
  # Create a student w/ name and grade attr and save it into the students table
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  # Create an instance with corresponding attribute values
  # DB will return an array of data for each row
  # Convert what the database gives us into a Ruby object
  def self.new_from_db(row)
    new_student = self.new(row[0], row[1], row[2]) #Same as running Student.new
    # new_student.id = row[0]
    # new_student.name = row[1]
    # new_student.grade = row[2]
    new_student
  end
  
  # Return an instance of student that matches the name from the DB
  def self.find_by_name(name)
    # Queries db table for a record w/ a name of the name passed in as an argument
    sql = "SELECT * FROM students where name = ?"
    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end
  
  # Update the record associated with a given instance
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
