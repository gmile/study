require 'rubygems'
require 'sinatra'
require 'haml'
require 'lexical_analyser'

before do
  puts '[Params]'
  p params
end

get '/' do
  @parser = Parser.new(params[:source])
  @parser.divide
  @parser.tokenize

  haml :index, :locals => { :output => @parser.output.flatten }
end

get '/stylesheets/style.css' do
  scss :style
end
