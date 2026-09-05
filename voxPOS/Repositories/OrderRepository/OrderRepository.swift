//
//  OrderRepository.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//
import Foundation

protocol OrderRepository {
    
    func getOrders() -> [Order]
    func createOrder(order: Order) -> Order?
    func updateOrder(order: Order) -> Order?
    func deleteOrder(order: Order) -> Bool?
    func addItem(item: OrderItem, toOrder: Order) -> Order
    func getOrder(byId: Int) -> Order
    func deteleItem(item: OrderItem, fromOrder: Order)
    func updateItem(item: OrderItem, fromOrder: Order)
    
}
