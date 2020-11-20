//
//  DetailedViewController.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 20.11.2020.
//

import UIKit
import Kingfisher

class DetailedViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var songsCount: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var copyright: UILabel!
    //Album entity
    var album: Result?
    //Array of songs info in tuples. This songs belong to the given album.
    var data: [(name: String, time: Double)] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        songsTable.dataSource = self
        APIHandler.shared.delegate = self
        fill()
    }
    /**Configures all elements of the controller with given album.*/
    private func fill() {
        guard let album = album else {
            return
        }
        //There is a small lifehack in this step. The defaul resolutions for artwork of an album are 60x60 and 100x100, but you can manually change this string piece in url string to any other resolution and get image with requested resolution.
        if let artURL = URL(string: album.artworkBig?.replacingOccurrences(of: "100x100bb.jpg", with: "400x400bb.jpg") ?? "") {
            artworkView.kf.setImage(with: ImageResource(downloadURL: artURL, cacheKey: artURL.absoluteString))
        }
        albumName.text = album.collectionName
        artistName.text = album.artistName
        songsCount.text = "\(album.trackCount) SONG" + (album.trackCount == 1 ? "" : "S")
        copyright.text = album.copyright?.uppercased()
        //Creating Date in fancy readable representation.
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = dateFormatter.date(from: "2018-10-05T12:00:00Z") {
            dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            releaseDate.text = "RELEASED " + dateFormatter.string(from: date).uppercased()
        }
        //Getting songs info
        APIHandler.shared.getAlbumSongs(albumId: album.collectionId, completionQueue: DispatchQueue.main, completionHandler: {result in
            self.data = result
            self.songsTable.reloadData()
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell") as? SongCell else {
            return UITableViewCell()
        }
        cell.data = data[indexPath.item]
        return cell
    }
}
