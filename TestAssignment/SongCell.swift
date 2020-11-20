//
//  SongCell.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 20.11.2020.
//

import UIKit

class SongCell: UITableViewCell {

    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var time: UILabel!
    //Configures cell appearance with self content.
    var data: (name: String, time: Double)? {
        didSet {
            guard let data = data else {
                songName.text = ""
                time.text = ""
                return
            }
            //Formates time from seconds to readable representation.
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            var outputString = formatter.string(from: data.time)
            if outputString?.first == "0" {
                outputString?.removeFirst()
            }
            songName.text = data.name
            time.text = outputString
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
