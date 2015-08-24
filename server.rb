require 'sinatra'
require 'csv'
require 'pg'


def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end

get "/articles" do
  ## Add the exsisting articles in the CSV to the database ##
  #
  # articles_array = []
  # CSV.foreach('articles.csv', headers: true, header_converters: :symbol) do |row|
	#   new_article = row.to_hash
	#   articles_array << new_article
  # end
  #
  # sql = ""
  # db_connection do |conn|
  #   articles_array.each do |x|
  #     sql = "INSERT INTO articles (title, url, description) VALUES('#{x[:title]}', '#{x[:url]}', '#{x[:description]}')"
  #     conn.exec(sql)
  #   end
  # end

results = db_connection do |conn|
  conn.exec('SELECT title, url, description FROM articles')
end

@results = results.to_a

  erb :index
end


get "/articles/new" do
  erb :new
end


post "/articles/new" do
  title = params['title']
  url = params['url']
  description = params['description']

  begin
    db_connection do |conn|
      conn.exec_params("INSERT INTO articles (title, url, description) VALUES( $1, $2, $3)", [title, url, description])
    end
    redirect '/articles'
  rescue
    redirect '/articles'
  end

  erb :new, locals: {title: param[:title], url: param[:url], description: param[:description]}
end
