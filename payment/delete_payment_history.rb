payment = Payment.find(3550)
payment.sub_payments.last.delete
payment.delete
