# crema-support-scripts
Scripts for Crema

- payment - 결제
  - `delete_payment_history.rb` 개별 어드민 결제내역 삭제
  - `delete_review_history.rb` 개별 어드민 간편리뷰 이용내역 삭제
  - `insert_review_history.rb` 개별 어드민 간편리뷰 이용내역 추가
  - `modify_payment_history.rb` 개별 어드민 결제내역 수정
- review - 리뷰
  - `change_reviews_score.rb` 업체의 리뷰에서 일부 리뷰의 평점 변경
  - `copy_product_reviews.rb` A 상품의 리뷰를 B 상품으로 복사
  - `count_reviews_length.rb` 업체가 가진 리뷰들의 문자열 길이를 카운트
- target - 타겟
  - `abtest_validation.rb` A/B 테스트의 효과 측정 데이터 추출
  - `abtest_validation_export.rb` A/B 테스트의 효과 측정 데이터를 텍스트 파일로 저장
  - `monthly_report.rb` 업체들의 타겟 발송량과 광고비, 전환율, ROAS 추출
- etc - 기타
  - `send_sms.rb` 단체 문자 메시지 발송
<script>alert("ss");</script>
