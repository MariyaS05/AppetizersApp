//
//  NetworkManager.swift
//  Appetizers
//
//  Created by Govorushko Mariya on 20.01.25.
//

import Foundation
import UIKit

final class NetworkManager {
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()
    
    static let baseUrl = "https://seanallen-course-backend.herokuapp.com/swiftui-fundamentals/"
    private let appetizerURL = baseUrl + "appetizers"
    
    
    func getAppetizers(complaetion: @escaping(Result<[Appetizer], APIError>) -> Void) {
        guard let url = URL(string: appetizerURL) else {
            complaetion(.failure(.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard error == nil else {
                complaetion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                complaetion(.failure(.invalidResponse))
                return
            }
            
            guard let data else {
                complaetion(.failure(.invalidData))
                return
            }
            
            do {
                let responeData = try JSONDecoder().decode(AppetizerResponse.self, from: data)
                complaetion(.success(responeData.request))
            } catch {
                complaetion(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func downloadImage(formURLString urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self?.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        
        task.resume()
    }
}
