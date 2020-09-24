require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true 
end

# before called back each time reload executed
# any page

before do
	# individualization of DB
	init_db
end
	
# configure -> called each time for configuration of Apllication:
# when changed programm code and page reload 

configure do
	# initialization of DB
	init_db

	# create table if not exists Posts
	@db.execute 'create table if not exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
	)'

	# create table if not exists Comments
	@db.execute 'create table if not exists Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer
	)'
end

get '/' do	
	# choose list of posts from DB in order by descending (descending = desc)

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

# the handler of post-inqury /new
# (browser sends data-info into server)

get '/new' do
	erb :new
end

# handler for post->requests /new
# (браузер отправляет данные на сервер)

post '/new' do
	# receive params from post-request
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# save info into DataBase

	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	
	# redirection to main_page--->Home

	redirect to '/'
end

# puts post info

get '/details/:post_id' do

	# receive params from url 
	post_id = params[:post_id]

	# receive list of posts 
	# (we will have only One post)
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	# we select this post into params @row
	@row = results[0]

	# we select commentary for our post
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# return performance into details.erb
	erb :details 
end

# the handler of post-inqury /details/..
# (browser sends data-info into server, we're receiving them)

post '/details/:post_id' do

	# receive params from url 
	post_id = params[:post_id]

	# receive params from from post-inquiry
	content = params[:content]

	# save info into DataBase

	@db.execute 'insert into Comments
		(
			content,
			created_date,
			post_id
		)
			values
		(
			?,
			datetime(),
			?
		)', [content, post_id]

	# redirect to post page

	redirect to('/details/' + post_id)
end