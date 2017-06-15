class Student
  attr_accessor :id, :name, :grade

  def self.new_from_db(row)
    self.new.tap do |student|
      student.id = row[0]
      student.name = row[1]
      student.grade = row[2]
    end
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
    SELECT * FROM students;
    SQL
    DB[:conn].execute(sql).instance_eval do |result_array|
      result_array.map {|row| Student.new_from_db(row)} #must do student, not self!
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ? LIMIT(1);
    SQL
    result = DB[:conn].execute(sql, name).first
    self.new_from_db(result)
  end

  def self.all_students_in_grade_x(grade)
    sql = <<-SQL
    SELECT * FROM students WHERE grade = ?;
    SQL
    result = DB[:conn].execute(sql, grade)
    #return array of student objects
    result.instance_eval do |result_array|
      result_array.collect {|row| Student.new_from_db(row)}
    end
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.count_all_students_in_grade_9
    self.all_students_in_grade_x(9)
  end

  def self.students_below_12th_grade
    query = "SELECT * FROM students WHERE grade < 12"
    results_array = DB[:conn].execute(query)
    results_array.collect{|row| self.new_from_db(row)}
  end

  def self.first_x_students_in_grade_10(num)
    query = "SELECT * FROM students WHERE grade = 10 LIMIT(?)"
    results_array = DB[:conn].execute(query, num)
    results_array.collect{|row| self.new_from_db(row)}
  end

  def self.first_student_in_grade_10
    query = "SELECT * FROM students WHERE grade = 10 LIMIT(1)"
    results_array = DB[:conn].execute(query)
    results_array.collect{|row| self.new_from_db(row)}[0]
  end

end
