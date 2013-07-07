class ArxivChecker
  include Sidekiq::Worker

  def perform
    # Paper.under_review
    Paper.where(:state => 'submitted').each_with_index do |paper, index|
      current_arxiv_id = latest_arxiv_id_for(paper)
      
      if paper.version != current_arxiv_id
        puts "Version has changed"
        paper.mark_all_issues_pending(current_arxiv_id)
      end
    end
  end

  def latest_arxiv_id_for(paper)
    return Arxiv.get(paper.arxiv_id).version
  end
end