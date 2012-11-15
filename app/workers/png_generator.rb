class PngGenerator
  include Sidekiq::Worker
  
  def perform(paper_id, pdf_url)
    arxiv_id = pdf_url.split('/').last
    `mkdir public/#{arxiv_id}`
    `cd tmp && curl -o #{arxiv_id}.pdf #{pdf_url}.pdf`
    `cd tmp && convert -density 300 #{arxiv_id}.pdf -bordercolor white -border 0 +adjoin #{arxiv_id}.png`
    `cd tmp && convert -density 300 #{arxiv_id}.pdf -bordercolor white -border 0 -resize 140 +adjoin #{arxiv_id}-small.png`
    `cd tmp && mv #{arxiv_id}* ../public/#{arxiv_id}`
  end
end