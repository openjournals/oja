
task :populate_with_test_data => :environment do

	User.delete_all
	Paper.delete_all

	papers=["1307.2896","1306.3876","1111.1184","0711.1860","0707.1594","1306.3876","0707.1594","0907.4011","1112.0495"]

	editor   = User.create(:email=>"editor@oja.org",   :first_name=> "e", :last_name=>"ditor",   :password=>"editor",   :password_confirmation =>"editor",   :roles=>["editor"] )
	reviewer = User.create(:email=>"reviewer@oja.org", :first_name=> "r", :last_name=>"eviewer", :password=>"reviewer", :password_confirmation =>"reviewer", :roles=>["reviewer"] )
	author1  = User.create(:email=>"author1@oja.org",  :first_name=> "a", :last_name=>"uthor",   :password=>"author1",  :password_confirmation =>"author1",  :roles=>["author"] )
	author2  = User.create(:email=>"author2@oja.org",  :first_name=> "a", :last_name=>"uthor",   :password=>"author2",  :password_confirmation =>"author2",  :roles=>["author"] )

	Paper.skip_callback(:create, :after, :pull_arxiv_details)

	papers.each do |p|
		manuscript = Arxiv.get(p)
		
		state = ["accepted", "under_review","submitted"].sample 
		if state == "submitted"
			reviewer_id = nil
		else
			reviewer_id = reviewer.id
		end

		p = Paper.create(
			:title => manuscript.title,
			:version => manuscript.version,
			:arxiv_id => p,
			:state => state,
			:pdf_url => manuscript.pdf_url,
			:authors => manuscript.authors.collect { |a| a.name },
			:submitted_at => manuscript.created_at,
			:category => manuscript.primary_category.abbreviation,
			:submitting_author_id => [author1, author2].sample.id,
			:github_address => "git@github.com:openja/#{p}.git",
			:reviewer_id => reviewer_id
			)

	end
	Paper.set_callback(:create)
end