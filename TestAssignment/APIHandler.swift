//
//  APIHandler.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 19.11.2020.
//

import Foundation
import UIKit

/// The class handles communication with iTunesSearch API in simple swifty way. This class has only one instanse in the application.
class APIHandler {
    /**Singleton instance for APIHandler class.*/
    static let shared = APIHandler("https://itunes.apple.com")
    /**Base URL for all requests.*/
    private let baseURL: String
    /**URLSessionTask for getting information from the server.*/
    private var task: URLSessionDataTask?
    /**Delegate reference for managing error alerts.*/
    var delegate: UIViewController?
    
    private init(_ url: String) {
        self.baseURL = url
    }
    /// Enumeration that determines for which attributes the search request performs.
    enum Key: String, CaseIterable {
        /**Searches through artist names.*/
        case artistName = "allArtistTerm"
        /**Searches through album names.*/
        case albumName = "albumTerm"
    }
    /// Performs search request with given string and search key. The result of the request is transfered to the completion block.
    /// - Parameters:
    ///   - searchString: The name of the album or the artist that is searched for.
    ///   - key: The key that determines the search request to be whether through artist names or through album names.
    ///   - completionQueue: The DispatchQueue on which the completion block will be executed.
    ///   - completionHandler: The block of code that is to be executed after the function returns. It stores the result of the performed request.
    func getAlbums(searchString: String, key: Key, completionQueue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping([Result]) -> Void) {
        //task cancellation before performing a new task
        task?.cancel()
        //Creation of the requests URL.
        var components = URLComponents(string: baseURL + "/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: searchString),
            URLQueryItem(name: "country", value: Locale.current.regionCode),
            URLQueryItem(name: "entity", value: "album"),
            URLQueryItem(name: "attribute", value: key.rawValue)
        ]
        guard let url = components?.url else {
            print("Can't get URL from URLComponents")
            self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with URL", buttonTitle: "Try Again Later")
            return
        }
        //Creation of a new task
        task = URLSession.shared.dataTask(with: url) {data, response, error in
            //Error check
            if let error = error, error.localizedDescription != "cancelled" {
                print("Data task finished with error: \(error.localizedDescription)")
                self.delegate?.generateAlert(title: "Data task error", message: error.localizedDescription, buttonTitle: "Try Again Later")
                return
            }
            //Checking for response status code from the server
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTPResponse status code: \(httpResponse.statusCode)")
                self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "Try Again Later")
                return
            }
            //Checking if there is data received from the server
            guard let data = data else {
                print("No data received")
                self.delegate?.generateAlert(title: "Oops!", message: "It seems to be no data here!", buttonTitle: "Try Again Later")
                return
            }
            //Decoding from JSON to Model
            let decoder = JSONDecoder()
            do {
                let albums = try decoder.decode(SearchResult.self, from: data)
                //Transfering the result to the completion handler
                completionQueue.async {
                    completionHandler(albums.results)
                }
            } catch {
                print("Can't decode data")
                self.delegate?.generateAlert(title: "Oops!", message: "Can't decode data.", buttonTitle: "Try Again Later")
                return
            }
        }
        task?.resume()
    }
    /// Performs request for gathering information about songs that are included in given album. The function stores its return value in the completion handler.
    /// - Parameters:
    ///   - albumId: The ID of the album which songs info needed.
    ///   - completionQueue: The DispatchQueue on which the completion block will be executed.
    ///   - completionHandler: The block of code that is to be executed after the function returns. It stores the result of the performed request.
    func getAlbumSongs(albumId: Int, completionQueue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping([(name: String, time: Double)]) -> Void) {
        //Cancelling previous task
        task?.cancel()
        //Making url query
        var components = URLComponents(string: baseURL + "/lookup")
        components?.queryItems = [
            URLQueryItem(name: "id", value: "\(albumId)"),
            URLQueryItem(name: "country", value: Locale.current.regionCode),
            URLQueryItem(name: "entity", value: "song")
        ]
        guard let url = components?.url else {
            print("Can't get URL from URLComponents")
            self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with URL", buttonTitle: "Try Again Later")
            return
        }
        //Creation of a new task
        task = URLSession.shared.dataTask(with: url) {data, response, error in
            //Error check
            if let error = error, error.localizedDescription != "cancelled" {
                print("Data task finished with error: \(error.localizedDescription)")
                self.delegate?.generateAlert(title: "Data task error", message: error.localizedDescription, buttonTitle: "Try Again Later")
                return
            }
            //Checking for respons status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTPResponse status code: \(httpResponse.statusCode)")
                self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "Try Again Later")
                return
            }
            //Checking if there is data in response
            guard let data = data else {
                print("No data received")
                self.delegate?.generateAlert(title: "Oops!", message: "It seems to be no data here!", buttonTitle: "Try Again Later")
                return
            }
            //Decoding jason into readable data
            guard let object = try? JSONSerialization.jsonObject(with: data, options: []), let resultJson = object as? Dictionary<String, Any>, let result = resultJson["results"] as? [Dictionary<String, Any>] else {
                print("Can't decode data")
                self.delegate?.generateAlert(title: "Oops!", message: "Can't decode data.", buttonTitle: "Try Again Later")
                return
            }
            var returningValue: [(name: String, time: Double)] = []
            result.forEach { dictionary in
                if let type = dictionary["kind"] as? String, type == "song" {
                    returningValue.append((name: dictionary["trackName"] as! String, time: Double((dictionary["trackTimeMillis"] as! Int) / 1000)))
                }
            }
            //Transfering result into completion handler
            completionQueue.async {
                completionHandler(returningValue)
            }
        }
        task?.resume()
    }
}
