phones = %w(

)

phones = %w(
  0100000000
)

from = Settings.crema_phone
subject = '<크리마 시스템 업데이트 공지>'
message = "<크리마 시스템 업데이트 공지>

안녕하세요. 크리마입니다.
크리마 시스템 기능개선 업데이트가 있었습니다.
이번 업데이트로 더 풍성한 기능을 제공할 수 있게 되었습니다.

업데이트된 기능 안내드리니 많은 관심 부탁드립니다.

[타겟DM]
- 필터명 변경
- 추천상품 진열 순서 변경

[간편리뷰]
- 리뷰 작성자명 숨김 기능

상세보기
https://assets.cre.ma/p/notice_images/00/00/00/02/13/image/74a2d5b9bd349bfa.png

서비스 문의 및 안내
T: 070-5102-2595
"

phones.each do |phone|
  SimpleSms.send_sms(from, phone, message, subject: subject, force: true)
end
