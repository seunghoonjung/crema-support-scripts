.where("created_at >= ? and created_at <= ?", "2015-11-12", "2016-08-02")

b = Brand.find(92)
b.shard do
  src_product = Product.find(946719)
  dst_product = Product.find(948085)

  reviews = src_product.reviews
  i = 0
  c = reviews.count
  reviews.each do |r|
    puts "#{r.created_at} #{r.user_name}"
    r_u = dst_product.reviews.where(user_username: r.user_username)
    if r_u.count
      new_review = r.dup
      new_review.mileage_amount = 0
      new_review.gave_mileage_at = nil
      new_review.mileage_message = nil
      new_review.product_id = dst_product.id
      new_review.product_name = dst_product.name
      new_review.product_image_url = dst_product.try(:image).try(:path_for_cache, :extra_small)
      new_review.product_url = dst_product.try(:url)
      new_review[:image1] = nil
      new_review[:image2] = nil
      new_review[:image3] = nil
      new_review[:image4] = nil
      new_review.code = nil
      new_review.review_source = WrittenSource::COPIED
      new_review.naver_blog_post_id = nil
      new_review.created_at = r.created_at
      new_review.save!

      # Image Copy after review created
      new_review.reload
      if r.images_count > 0
        (1..r.images_count).each do |j|
          begin
            source_url = r.send("image#{j}_url", protocol: 'http')
            puts "COPY IMAGE FROM #{source_url}"
            new_review.send("remote_image#{j}_url=", source_url)
          rescue
            puts "raise review_#{r.id}, j:#{j}, image_url: #{source_url}"
          end
        end
        new_review.images_count = r.images_count
      end
      new_review.save!

      # Comment copy
      r.comments.each do |comment|
        new_comment = comment.dup
        new_comment.review_id = new_review.id
        new_comment.written_source = WrittenSource::COPIED
        new_comment.code = nil
        new_comment.created_at = comment.created_at
        new_comment.save(validate: false)
      end

      i += 1
      puts "#{i}/#{c}review #{r.id} copy to #{new_review.id}"
    end
  end && false

  dst_product.cache_reviews!
end