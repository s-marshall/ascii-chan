require 'sinatra'
require 'haml'
require 'pg'


def double_the_single_quotes!(s)
  s.gsub!(%Q{'}, %Q(''))
end

class Art
  @db = nil

  def initialize
    @db = PG::Connection.new
    @sql = %Q{DROP DATABASE IF EXISTS artdb}
    @db.exec(@sql)

    @sql = %Q{CREATE DATABASE artdb}
    @db.exec(@sql)

    @sql = %Q{DROP TABLE IF EXISTS works_of_art}
    @db.exec(@sql)

    @sql = %Q{CREATE TABLE works_of_art ( \
    						title varchar(80), \
    						work_of_art varchar(90000), \
    						created timestamp DEFAULT current_timestamp); \
    						}
    @db.exec(@sql)
  end

  def add_artwork(title, artwork)
    double_the_single_quotes!(artwork)
    @sql = "INSERT INTO works_of_art VALUES ('#{title}', '#{artwork}');"
    @db.exec(@sql)
  end

  def collection
    @sql = "SELECT * FROM works_of_art ORDER BY created DESC;"
    @db.exec(@sql).values
  end
end

class FrontMatter
  attr_accessor :title, :art

  def initialize
    @title = ''
    @art = ''
  end
end

def render_front(title = '', artwork = '', error = '', gallery = nil)
  art_gallery = []
  art_gallery = gallery.collection unless gallery == nil
  haml :front, :locals => {:title => title, :artwork => artwork, :error => error, :art_gallery => art_gallery}
end

gallery = Art.new
front = FrontMatter.new

get '/' do
  render_front(front.title, front.art, params[:error], gallery)
end

post '/' do
  title = params[:title]
  artwork = params[:artwork]
  error = ''

  if title.length > 0 && artwork.length > 0
    front.title = params[:title]
    front.art = params[:artwork]
    gallery.add_artwork(title, artwork)
    redirect '/'
  else
    error = 'Add missing title and/or artwork!'
    render_front(title, artwork, error)
  end
end