# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def parse_json
    File.open('memo.json', 'r') do |file|
      data = file.read
      if data == ''
        {}
      else
        JSON.parse(data)
      end
    end
  end
end

get '/memo' do
  @memos = parse_json
  erb :index
end

get '/' do
  redirect '/memo'
end

get '/memo/new' do
  erb :new_memo
end

post '/memo/save' do
  @title = params[:title]
  @text = params[:text]
  memos = parse_json
  id = if !memos.empty?
         memos.keys.last.to_i + 1
       else
         0
       end
  memo = { id => { title: @title, text: @text } }
  memos = memos.merge(memo)
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end

get '/memo/edit/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :edit_memo
end

patch '/memo/edit/:id' do |id|
  title = params[:title]
  text = params[:text]
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  memos[id]['title'] = title
  memos[id]['text'] = text
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end

get '/memo/show/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  @title = memos[id]['title']
  @text = memos[id]['text']
  @id = id
  erb :show_memo
end

delete '/memo/delete/:id' do |id|
  memos = File.open('memo.json', 'r') do |file|
    data = file.read
    JSON.parse(data)
  end
  memos.delete(id)
  File.open('memo.json', 'w') do |file|
    JSON.dump(memos, file)
  end
  redirect '/'
end
