desc 'Bundle application and upload it to S3'
task :bundle_app do
  require 'aws-sdk'
  AWS.config access_key_id: '', secret_access_key: ''
  
  # hang onto the working branch
  working_branch = `git rev-parse --abbrev-ref HEAD`.chomp
  
  # switch to the deploy branch
  `git checkout -b bundled_deploy`
  
  root = Dir.pwd
  `mkdir -p vendor/cache`
  
  # find all gemspecs in vendor, build them, cache them, and add to the commit
  Dir['vendor/gems/**/*.gemspec'].each do |gemspec|
    dirname = File.dirname gemspec
    specname = File.basename gemspec
    name = specname.sub /\.gemspec$/, ''
    
    Dir.chdir dirname
    `gem build #{ specname }`
    
    gemfile = Dir["#{ name }*.gem"][0]
    Dir.chdir root
    gempath = File.join(dirname, gemfile)
    `mv #{ gempath } vendor/cache`
    `git add -f vendor/cache/#{ gemfile }`
  end
  
  `bundle install --local --without test development`
  
  # precompile assets
  `rm -rf public/assets`
  `rake assets:precompile`
  
  # package the gems
  `bundle package`
  
  # commit the changes
  `git add -f public/assets`
  `git add -f vendor/cache`
  `git commit -a -m "deploying"`
  
  # export the app
  `git archive -o theoj.tar HEAD`
  `gzip theoj.tar`
  
  # S3 setup
  s3 = AWS::S3.new
  bucket = s3.buckets['zooniverse-code']
  old_bundle = bucket.objects['theoj.tar.gz']
  
  # move the old bundle if it exists
  if old_bundle.exists?
    timestamp = old_bundle.last_modified.strftime('%H%M-%d%m%y')
    old_bundle.move_to "theoj-#{ timestamp }.tar.gz"
  end
  
  # upload the new bundle
  print 'Uploading...'
  new_bundle = bucket.objects['theoj.tar.gz']
  new_bundle.write file: 'theoj.tar.gz'
  puts '...done'
  `rm -f theoj.tar.gz`
  
  `rm -rf .bundle`
  `rm -rf vendor/cache`
  
  # checkout the working branch
  `git checkout #{ working_branch }`
  `git branch -D bundled_deploy`
end
