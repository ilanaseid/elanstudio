# added because of #102624902 https://www.pivotaltracker.com/story/show/102624902
if ENV["RAILS_GROUPS"] == 'assets'
  Excon.defaults[:nonblock] = false
end
