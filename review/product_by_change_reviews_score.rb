Brand.fbc('flexin.co.kr').shard do
  review_max_score = 5
  review_want_score = 4.89

  products = Product.all
  products.each do |p|
    reviews_count = p.reviews.count
    review_max_score_total = (review_max_score * reviews_count).to_int
    review_want_score_total = (review_want_score * reviews_count).to_int
    reviews_sample_count = review_max_score_total - review_want_score_total
    reviews_sample = p.reviews.sample(reviews_sample_count)

    reviews_sample.each do |r|
      r.score = 4
      r.save
    end
  end ; nil
end