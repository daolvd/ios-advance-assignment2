//
//  LocalPaymentRepositoy.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

class LocalPaymentRepository : PaymentRepository {
   
    func paymentHistory() -> [Payment] {
        //
        return []
    }
    
    func approvedPayment(orderID: String) -> Payment? {
        //
        return nil
    }
    
    func recordPaymentAttempt(_ payment: Payment) throws {
        //
    }
    
    
}
