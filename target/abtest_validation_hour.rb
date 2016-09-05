class AbTestStats
  def self.stats(brand_code, ab_test_id, span)
    new(brand_code, ab_test_id, span)
  end

  def initialize(brand_code, ab_test_id, span)
    @brand = Brand.fbc(brand_code)
    @ab_test_id = ab_test_id
    @span = span
    brand.shard {stats}
  end

  private

  attr_reader :sub_orders, :brand, :ab_test_cohorts, :ab_test_id, :results, :span, :summary

  def stats
    load_abtest_cohorts
    analyze
    display_result
  end

  def load_abtest_cohorts
    ab_test = Target::AbTest.find(ab_test_id)
    @ab_test_cohorts =  ab_test.
                        cohorts.
                        where.not(main_cohort_id: nil).
                        to_a
  end

  def analyze
    @results = []
    @summary = {sent: {sent_count: 0, orders_count: 0}, mute: {sent_count: 0, orders_count: 0}}
    ab_test_cohorts.each do |cohort|
      @sub_orders = nil
      next unless cohort.dispatched?
      cohort_result = OpenStruct.new(
        main_cohort_id: cohort.main_cohort_id,
        sent_date: cohort.sent_at.to_date,
        type: cohort.cohort_index == 1 ? 'sent' : 'mute',
        sent_count: load_sent_items(cohort).count,
        orders_count: sub_orders(cohort).map(&:order_id).uniq.count,
        ad_spending: cohort.ad_spending,
        revenu: sub_orders(cohort).map(&:price).reduce(&:+).to_i
      )
      @results << cohort_result
      @summary[:"#{cohort_result.type}"][:sent_count] += cohort_result.sent_count
      @summary[:"#{cohort_result.type}"][:orders_count] += cohort_result.orders_count
    end
  end

  def load_sent_items(cohort)
    cohort.items.
      joins("LEFT OUTER JOIN `sms` ON `sms`.`sendable_id` = `target_cohort_items`.`id` AND `sms`.`sendable_type` = 'Target::Cohort::Item'").
      joins("LEFT OUTER JOIN `emails` ON `emails`.`sendable_id` = `target_cohort_items`.`id` AND `emails`.`sendable_type` = 'Target::Cohort::Item'")
  end

  def sub_orders(cohort)
    unless @sub_orders
      sent_date = cohort.sent_at
      end_date  = sent_date + span.hours
      date_span = sent_date..end_date

      brand_user_ids = cohort.items.select(:brand_user_id)
      @sub_orders = SubOrder.without_test.where(brand_user_id: brand_user_ids)
      @sub_orders = if cohort.filter_type?(:unpaid_order_filter)
                      load_sub_orders_unpaid(sub_orders: @sub_orders, date_span: date_span)
                    else
                      load_sub_orders_default(sub_orders: @sub_orders, date_span: date_span)
                    end
    end
    @sub_orders
  end

  def load_sub_orders_unpaid(sub_orders:, date_span:)
    order_ids = Order.where(purchased_at: date_span).select(:id)
    sub_orders.where(order_id: order_ids).to_a
  end

  def load_sub_orders_default(sub_orders:, date_span:)
    sub_orders.where(created_at: date_span).to_a
  end

  def display_result
    puts "Brand: #{brand.name}"
    puts "AB test ID: #{ab_test_id}"
    puts "Date span: #{span} Hours"
    puts '-----------------------------'
    results.each do |result|
      puts "Main_cohort: #{result.main_cohort_id}, Sent_date: #{result.sent_date}, Type: #{result.type}, Sent_count: #{result.sent_count}, Orders: #{result.orders_count}, Conversion: #{conversion(result.orders_count, result.sent_count)}, ROAS: #{conversion(result.revenu, result.ad_spending)}"
    end
    puts '-----------------------------'
    puts "SENT ALL -> SENT : #{summary[:sent][:sent_count]}, ORDER: #{summary[:sent][:orders_count]}, Conversion: #{conversion(summary[:sent][:orders_count], summary[:sent][:sent_count])}"
    puts "MUTE ALL -> SENT : #{summary[:mute][:sent_count]}, ORDER: #{summary[:mute][:orders_count]}, Conversion: #{conversion(summary[:mute][:orders_count], summary[:mute][:sent_count])}"
  end

  def conversion(first, last)
    return 0 unless first && last && first > 0 && last > 0
    (first / last.to_f * 100).round(1)
  end
end

AbTestStats.stats('pinkelephant.co.kr', 1, 3)