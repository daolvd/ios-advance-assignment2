//
//  LocalOrderRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

class LocalOrderRepository: OrderRepository {
    func getOrders() -> [Order] {
        
        return []
    }
    
    func createOrder(order: Order) -> Order? {
        
        return nil
    }
    
    func updateOrder(order: Order) -> Order? {
        
        return nil
    }
    
    func deleteOrder(order: Order) -> Bool? {
        
        return nil
    }
    
    func addItem(item: OrderItem, toOrder: Order) -> Order {
        
        return  Order(orderNumber: 0)
    }
    
    func getOrder(byId: Int) -> Order {
        
        return  Order(orderNumber: 0)
    }
    
    func deteleItem(item: OrderItem, fromOrder: Order) {
        
    }
    
    func updateItem(item: OrderItem, fromOrder: Order) {
        
    }
    

 
    
}
