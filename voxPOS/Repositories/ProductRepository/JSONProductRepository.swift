//
//  JSONProductRepository.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 21/8/2026.
//

import Foundation

class JSONProductRepository: ProductRepository {
    private(set) var products: [Product] = []

    private let fileURL: URL

    init() {
        let fileManager = FileManager.default

        let documentsURL = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        fileURL = documentsURL.appendingPathComponent("SampleProducts.json")

        // Copy the bundled JSON to Documents the first time
        if !fileManager.fileExists(atPath: fileURL.path) {
            if let bundledURL = Bundle.main.url(
                forResource: "SampleProducts",
                withExtension: "json"
            ) {
                try? fileManager.copyItem(
                    at: bundledURL,
                    to: fileURL
                )
            }
        }

        products = load()
    }

    func load() -> [Product] {
        do {
            let data = try Data(contentsOf: fileURL)

            return try JSONDecoder().decode(
                [Product].self,
                from: data
            )
        } catch {
            print("Failed to load products: \(error)")
            return []
        }
    }

    func add(_ product: Product) {
        products.append(product)
        save()
    }

    func update(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
            save()
        }
    }

    func delete(_ product: Product) {
        products.removeAll { $0.id == product.id }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(products)

            try data.write(
                to: fileURL,
                options: .atomic
            )
        } catch {
            print("Failed to save products: \(error)")
        }
    }
}
