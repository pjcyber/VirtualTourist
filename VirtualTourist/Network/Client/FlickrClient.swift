//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Pjcyber on 4/29/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import Foundation

class  FlickrClient {
    
    enum Endpoints {
        
        static let key = "f75c81468aed91ba84e2d8c86268ec4d"
        
        case album(String, String, String)
        case image(String, String, String, String)
        
        var stringValue: String {
            switch self {
            case .album(let latitude, let longitude, let count):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Endpoints.key)&format=json&lat=\(latitude)&lon=\(longitude)&per_page=\(count)&page=1"
            case .image(let farm, let server, let photoId, let secret):
                return "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            let range: CountableRange = 14..<data!.count-1
            let newData = data?.subdata(in: range) /* subset response data! */
            
            guard let data = newData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func fethAlbum(pin: Pin!, count: String, completion: @escaping ([PhotoResponse], Error?) -> Void) {
        _ = taskForGETRequest(url: Endpoints.album(pin.latitude!, pin.longitude!, count).url, responseType: Album.self) { response, error in
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func downloadImage(photo: PhotoResponse!, completion: @escaping (String, Data?, Error?) -> Void) {
        URLSession.shared.dataTask(with: Endpoints.image(String(photo.farm), photo.server, photo.id, photo.secret).url) { data, response, error in
            let url = Endpoints.image(String(photo.farm), photo.server, photo.id, photo.secret).stringValue
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil
                else {
                    completion(url, nil, error)
                    return
            }
            completion(url, data, nil)
        }.resume()
    }
}
