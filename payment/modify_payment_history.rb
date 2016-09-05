rt = ReviewTransaction.find(197430)
# ReviewEventType에 대한 enum값은 crema-rails/app/enums/review_event_type.rb에서 확인
rt.review_event_type = ReviewEventType::RETURN
rt.save
