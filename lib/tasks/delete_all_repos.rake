desc 'Delete all GitHub repos'
task :delete_all_repos => :environment do
  repos = GITHUB_CONNECTION.list_repositories

  repos.each do |repo|
    GITHUB_CONNECTION.delete_repository("#{repo.full_name}")
  end
end
