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
  
  @output = @parser.output
  puts @output
#  @words = params[:words]
  haml :index
end
