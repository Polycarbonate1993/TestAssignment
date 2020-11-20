//
//  AlbumCell.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 19.11.2020.
//

import UIKit
import Kingfisher

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    //Configures appearance of a cell with self content.
    var album: Result? {
        didSet {
            if let artURL = URL(string: album?.artworkBig?.replacingOccurrences(of: "100x100bb.jpg", with: "400x400bb.jpg") ?? "") {
                artworkView.kf.setImage(with: ImageResource(downloadURL: artURL, cacheKey: artURL.absoluteString))
            } else {
                artworkView.image = UIImage(named: "placeholder")
            }
            albumName.text = album?.collectionName
            artistName.text = album?.artistName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        artworkView.image = UIImage(named: "placeholder")
        albumName.text = ""
        artistName.text = ""
    }
}
