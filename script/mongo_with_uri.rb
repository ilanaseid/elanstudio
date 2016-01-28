require 'moped'

@db_dir   = ARGV[0]
@app_name = ARGV[1]
@action   = ARGV[2]

if @app_name.strip.downcase == "production" && @action.strip.downcase == "push"
  puts "Alert: You are about to PUSH to PRODUCTION"
  puts "Please type 'confirm' to continue (will overwrite MongoDB on production) > "
  @push_confirmation = $stdin.gets.chomp
  if @push_confirmation != "confirm"
    puts "Not pushing to production, thank you."
    exit
  end
end

# https://github.com/heroku/toolbelt/issues/53 << because of this we must run Bundler.with_clean_env
@mongolab_uri = Bundler.with_clean_env { `heroku config:get MONGOLAB_URI --app #{@app_name}` }
@session      = Moped::Session.connect(@mongolab_uri)
@primary      = @session.cluster.nodes.select(&:primary?).first
@credentials  = @primary.credentials.flatten

@database = @credentials[0]
@username = @credentials[1][0]
@password = @credentials[1][1]

puts "Working with this Mongolab URI: #{@mongolab_uri}"
puts "About to #{@action} #{@app_name}..."

if @action.downcase == "pull"
  system("mongodump -h #{@primary.address.original} -d #{@database} -u #{@username} -p #{@password} -o #{@db_dir}")
  system("mongorestore --db theline_development --drop #{@db_dir}/#{@database}")
elsif @action.downcase == "push"
  system("mongorestore -h #{@primary.address.original} -u #{@username} -p #{@password} --db #{@database} --drop #{@db_dir}/theline_development")
else
  puts "There was an error. Please specifiy 'pull' or 'push' in call to Mongo script."
end
