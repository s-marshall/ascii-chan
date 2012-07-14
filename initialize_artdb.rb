require 'pg'

=begin
Before running this program,
create the Postgresql database named artdb by running:
  createdb artdb
=end

def connect_database
  begin
    db = PG.connect( :dbname => 'artdb' )
  rescue PGError
    puts 'Failed to connect to artdb database.'
  end
  return db
end

def create_table(db)
  sql = "CREATE TABLE works_of_art (
	  title varchar(80) NOT NULL,
	  work_of_art varchar(90000) NOT NULL,
	  created timestamp DEFAULT current_timestamp
	  );"
  begin
    db.exec(sql)
  rescue
    puts 'Failed to create art table in artdb.'
  ensure
    db.close unless db.nil?
    puts 'Database closed.'
  end
end

db = connect_database
create_table(db)

