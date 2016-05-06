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

class SongCell: UITableViewCell {
    
    var selectedSong: MPMediaItem!
    let outputSettings: [String:Int] =
        [ AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVLinearPCMIsBigEndianKey: 0,
          AVLinearPCMIsFloatKey: 0,
          AVLinearPCMBitDepthKey: 16,
          AVLinearPCMIsNonInterleaved: 0]
    
    @IBOutlet weak var songLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(song: MPMediaItem) {
        songLbl.text = song.title
    }
    
    func setSong(song: MPMediaItem) {
        selectedSong = song
    }
    
    func createWavOfSelectedSong() {
        
        if let songUrl = selectedSong.assetURL {
            let asset = AVURLAsset(URL: songUrl)
            
            let time: CMTime
            
            
            do {
                let reader = try AVAssetReader(asset: asset)
                let track = asset.tracksWithMediaType(AVMediaTypeAudio)[0]
                let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
                reader.addOutput(output)
                reader.startReading()
                let sampleBuffer = output.copyNextSampleBuffer()
                
                
                
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
            
            print(selectedSong.title)
            
            
        }
        
    }
    
}
