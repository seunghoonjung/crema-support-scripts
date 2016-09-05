Brand.fbc('angs.co.kr').shard {

  products = Product.all
  products.each do |p|
    reviews = p.reviews.where("created_at < ? and score >= ?", "2016-08-18", "4")
    reviews_num = reviews.count
    if reviews_num > 100
      score3_reviews_num = 4
      score2_reviews_num = 2
      score1_reviews_num = 1
    elsif reviews_num <= 100 and reviews_num > 50
      score3_reviews_num = 2
      score2_reviews_num = 1
      score1_reviews_num = 1
    elsif reviews_num <= 50 and reviews_num > 10
      score3_reviews_num = 1
      score2_reviews_num = 1
      score1_reviews_num = 0
    elsif reviews.count <= 10
      score3_reviews_num = 0
      score2_reviews_num = 0
      score1_reviews_num = 0
    else
      score3_reviews_num = 0
      score2_reviews_num = 0
      score1_reviews_num = 0
    end
    puts "============================================="
    puts "제품명: #{p.name}"
    #3점 작업
    if score3_reviews_num < 1
      puts "No change."
    else
      reviews.sample(score3_reviews_num).each do |r|
        puts "#{r.product_name}   /   ID: #{r.name}    /   Original Score: #{r.score}   /   Changed Score: 3"
        r.score = 3
        r.save
      end
    end


    #2점 작업
    if score2_reviews_num < 1
      puts "No change."
    else
      reviews.sample(score2_reviews_num).each do |r|
        puts "#{r.product_name}   /   ID: #{r.name}    /   Original Score: #{r.score}   /   Changed Score: 2"
        r.score = 2
        r.save
      end
    end


    #1점 작업
    if score1_reviews_num < 1
      puts "No change."
    else
      reviews.sample(score1_reviews_num).each do |r|
        puts "#{r.product_name}   /   ID: #{r.name}    /   Original Score: #{r.score}   /   Changed Score: 1"
        r.score = 1
        r.save
      end
    end

  end
}
