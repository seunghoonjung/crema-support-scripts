class ReviewMessage
  def initialize(brands)
    @brands = brands
  end

  def length
    brands.each do |brand|
      brand = Brand.fbc(brand)
      brand.shard do
        load_brand_name(brand)
        load_review_message_length
        print_length
      end
    end
  end

  private

  attr_reader :brands, :brand_name, :all_words_count, :all_words_count, :last_3month_words_count, :last_year_words_count, :last_2year_words_count

  def load_review_message_length
    @all_words_count = count_words(all)
    @last_3month_words_count = count_words(last_3month)
    @last_year_words_count = count_words(last_year)
    @last_2year_words_count = count_words(last_2year)
  end

  def print_length
    puts "[#{brand_name}] REVIEW MESSAGE LENGTH"
    puts "all_words_count: #{all_words_count}, review_count: #{all.count}, avg_review_words: #{all_words_count/all.count}"
    puts "last_2year_words_count: #{last_2year_words_count}, avg_month: #{last_2year_words_count/12/2}, review_count: #{last_2year.count}, avg_review_words: #{last_2year_words_count/last_2year.count}"
    puts "last_year_words_count: #{last_year_words_count}, avg_month: #{last_year_words_count/12}, review_count: #{last_year.count}, avg_review_words: #{last_year_words_count/last_year.count}"
    puts "last_3month_words_count: #{last_3month_words_count}, avg_month: #{last_3month_words_count/3}, review_count: #{last_3month.count}, avg_review_words: #{last_3month_words_count/last_3month.count}"
    puts "--------------------------------------------"
  end

  def load_brand_name(brand)
    @brand_name = brand.name
  end

  def all
    @all_words = Review.all
  end

  def last_3month
    Review.where('created_at > ?', 3.month.ago)
  end

  def last_year
    Review.where('created_at > ?', 1.year.ago)
  end

  def last_2year
    Review.where('created_at > ?', 2.year.ago)
  end

  def count_words(reviews)
    reviews.map { |r| r.message.chars_length }.reduce(:+)
  end
end

# 사용예시
ReviewMessage.new(['pinksisly.com', 'oznara.co.kr']).length
