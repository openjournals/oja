module SubmissionsHelper
  def png_for_page(page, paper)
    "https://raw.github.com/openja/#{paper.arxiv_id}/master/oja_pngs_#{paper.arxiv_id}/#{paper.arxiv_id}-small-#{page-1}.png"
  end
end
