class AbTestStats
  def self.stats(brand_code, ab_test_id, span)
    new(brand_code, ab_test_id, span)
  end


  def initialize(brand_code, ab_test_id, span)
    @brand = Brand.fbc(brand_code)
    @brandname = Brand.fbc(brand_code).name
    @linked_result = nil
    @span = span
    return 'Wrong brand' unless brand
    brand.shard do
      @ab_test = Target::AbTest.find(ab_test_id)
      return 'Wrong ab test id' unless ab_test
      stats
    end
  end

  private

  attr_reader :sub_orders, :brand, :ab_test_cohorts, :results, :ab_test, :span


  def stats
    load_abtest_cohorts
    analyze
    #display_result
  end


  def load_abtest_cohorts
    @ab_test_cohorts =  ab_test.
                        cohorts.
                        where.not(main_cohort_id: nil).
                        group_by(&:main_cohort_id).map(&:last).
                        flatten
  end


  def analyze
    @results = []
    ab_test_cohorts.each do |cohort|
      clear_sub_orders
      sant_raw_data(cohort)
      order_raw_data(cohort)
      #next unless cohort.dispatched?
      #@results << {
      #  main_cohort_id: cohort.main_cohort_id,
      #  sent_date: cohort.sent_at.to_date,
      #  type: cohort.cohort_index == 1 ? 'Sent' : 'Mute',
      #  sent_count: load_sent_items(cohort).count,
      #  orders_count: sub_orders(cohort).map(&:order_id).uniq.count,
      #  ad_spending: cohort.ad_spending,
      #  revenu: sub_orders(cohort).map(&:price).reduce(&:+).to_i
      #}
    end
  end


  def load_sent_items(cohort)
    cohort.items.
      joins("LEFT OUTER JOIN `sms` ON `sms`.`sendable_id` = `target_cohort_items`.`id` AND `sms`.`sendable_type` = 'Target::Cohort::Item'").
      joins("LEFT OUTER JOIN `emails` ON `emails`.`sendable_id` = `target_cohort_items`.`id` AND `emails`.`sendable_type` = 'Target::Cohort::Item'")
  end


  def clear_sub_orders
    @sub_orders = nil
  end


  def export_result
    ResultFile = File.new("[#{@brandname}] #{cohort.ab_test.name}_#{@span}일.txt", "w+")
    if ResultFile
       ResultFile.syswrite(@linked_result)
    else
       puts "Unable to open file!"
    end
  end


  def sub_orders(cohort)
    unless @sub_orders
      sent_date = cohort.sent_at
      start_date = sent_date
      end_date   = (sent_date + span.days)
      date_span = start_date..end_date

      brand_user_ids = cohort.items.select(:brand_user_id)
      @sub_orders = SubOrder.without_test.where(brand_user_id: brand_user_ids)
      @sub_orders = load_sub_orders_unpaid(sub_orders: @sub_orders, date_span: date_span)
    end
    @sub_orders
  end


  def load_sub_orders_unpaid(sub_orders:, date_span:)
    order_ids = Order.where(purchased_at: date_span).select(:id)
    sub_orders.where(order_id: order_ids).to_a
  end


  def display_result
    @linked_result += "Brand: #{brand.name}\n"
    @linked_result += "AB test ID: #{ab_test.id}\n"
    @linked_result += "Date span: #{span} Days\n"
    @linked_result += '-----------------------------\n'
    results.each do |result|
      @linked_result += "Main_cohort: #{result[:main_cohort_id]}, Sent_date: #{result[:sent_date]}, Type: #{result[:type]}, Sent_count: #{result[:sent_count]}, Orders: #{result[:orders_count]}, Conversion: #{conversion(result[:orders_count], result[:sent_count])}, ROAS: #{conversion(result[:revenu], result[:ad_spending])}\n"
    end
    @linked_result += '-----------------------------\n'
  end


  def conversion(first, last)
    return 0 unless first && last && first > 0 && last > 0
    (first / last.to_f * 100).round(1)
  end


  def sant_raw_data(cohort)
    target_cohort = load_sent_items(cohort)
    @linked_result += "\n"
    user_results = ''
    if cohort.cohort_index == 1
      @linked_result += '=============================\n'
      @linked_result += "Filter: #{cohort.ab_test.name}, Target_Group: #{cohort.ab_test.target_group_id}\n"
      @linked_result += "Sent : #{target_cohort.count}, Sent_at: #{cohort.sent_at}\n"
      target_cohort.each do |t|
        user_results = user_results + BrandUser.find(t.brand_user_id).username + ","
      end
    else
      @linked_result += '=============================\n'
      @linked_result += "Filter: #{cohort.ab_test.name}, Target_Group: #{cohort.ab_test.target_group_id}\n"
      @linked_result += "Mute : #{target_cohort.count}, Sent_at: #{cohort.sent_at}\n"
      target_cohort.each do |t|
        user_results = user_results + BrandUser.find(t.brand_user_id).username + ","
      end
    end
    @linked_result += "#{user_results}\n"
  end


  def order_raw_data(cohort)
    lineWidth = 70
    orders = sub_orders(cohort).map(&:order_id).uniq
    orders_count = orders.count
    @linked_result += '\n'
    @linked_result += "Order : #{orders_count}\n"
    user_results = ''
    orders.each do |o|
      order = Order.find(o)
      username_purchase = order.brand_user.username.ljust(lineWidth / 2) + ("(" + order.purchased_at.to_s + ")").center(lineWidth / 2) + ("(Response time: " + ((order.purchased_at - cohort.sent_at).to_i / 3600).to_s + " hours)").rjust(lineWidth / 2) + "\n"
      user_results = user_results + username_purchase
    end
    @linked_result += "#{user_results}\n"
    @linked_result += '=============================\n'
  end
end

AbTestStats.stats('vivaruby.co.kr', 2, 3)
