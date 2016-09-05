brand = Brand.find(1453)
description = "간편리뷰 6개월 * 10만 특별가 (600,000원) 카드 결제"
ReviewTransaction.create!(
  brand_id: brand.id,
  review_event_type: ReviewEventType::PAYMENT,
  description: description,
  review_default_sms_count: brand.review_default_sms_count,
  review_paid_sms_price: brand.review_paid_sms_price,
  created_at: "2016-08-24 13:55:00"
)
