require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    #first you insert a new instance into the database using SQL
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?, ?);
    SQL

    #run sql through database and you have to pass it the name and grade of the instance
    #this creates this new object instance in the database
    DB[:conn].execute(sql, name, grade);

    #this is the new_student record in the database returned as a double array
    new_student = DB[:conn].execute("SELECT * FROM students ORDER BY id DESC LIMIT 1");

    #now you have to grab the id created by the database and re-assign it
    #to the object created in ruby

    @id = DB[:conn].execute("SELECT * FROM students ORDER BY id DESC LIMIT 1")[0][0]

  end

  def self.create(hash)
    DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?,?)", hash[:name], hash[:grade]);

    id = DB[:conn].execute("SELECT last_insert_rowid() FROM students");
    new_student_record = DB[:conn].execute("SELECT * FROM students ORDER BY id DESC LIMIT 1")
    new_student_record = new_student_record.flatten
    Student.new(new_student_record[1], new_student_record[2], new_student_record[0])
  end

end
