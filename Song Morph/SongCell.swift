//
//  SongCell.swift
//  Song Morph
//
//  Created by Luke Morse on 5/4/16.
//  Copyright © 2016 Luke Morse. All rights reserved.
//

import UIKit
import MediaPlayer
import AudioToolbox
import AVFoundation
import OpenAL

class SongCell: UITableViewCell, NSStreamDelegate {
    
    var selectedSong: MPMediaItem!
    
    let audioPlayer = LMAudioPlayer()
    
    @IBOutlet weak var songLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        audioPlayer.createWavOfSelectedSong(selectedSong)
    }
    
    func configureCell(song: MPMediaItem) {
        songLbl.text = song.title
    }
    
    func setSong(song: MPMediaItem) {
        selectedSong = song
    }
    
    
    

    
}
