# 업체명 // 장바구니발송량 // 전체 발송량 // 광고비 // 전환율 // ROAS
start_date = '2016-07-01'
end_date = '2016-07-31'
title = 0
Brand.using_target.order(id: :asc).each_shard do |b|
  reports = Target::Report.joins(:cohort).merge(Target::Cohort.main).where(date: start_date..end_date)

  cart_item_group = Target::Group.find_by(name: '장바구니 리마인딩')
  if cart_item_group
    cart_item_reports = reports.where(target_cohorts: {target_group_id: cart_item_group.id})
    cart_item_group_total_report = Target::Report::AsRange.new(date: start_date, end_date: end_date, interval: :total, reports: cart_item_reports, group: cart_item_group)
    cart_item_group_sent_count = cart_item_group_total_report.sent_count
  else
    cart_item_group_sent_count = 0
  end

  total_report = Target::Report::AsRange.new(date: start_date, end_date: end_date, interval: :total, reports: reports)

  brand_name = b.name
  sent_count = total_report.sent_count
  ad_spending = total_report.ad_spending
  conversion_rate = (total_report.conversion_rate * 100).round(1)
  roas = total_report.roas

  if title == 0
    puts "업체명, 장바구니 발송량, 전체 발송량, 광고비, 전환율, ROAS"
  end
  title = 1
  puts "#{brand_name},#{cart_item_group_sent_count},#{sent_count},#{ad_spending},#{conversion_rate},#{roas}"
end && false
