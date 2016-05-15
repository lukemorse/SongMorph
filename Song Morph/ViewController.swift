//
//  ViewController.swift
//  Song Morph
//
//  Created by Luke Morse on 5/2/16.
//  Copyright © 2016 Luke Morse. All rights reserved.
//

import UIKit
import MediaPlayer

let mediaItems = MPMediaQuery.songsQuery().items

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let song = mediaItems![indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("SongCell") as? SongCell {
            cell.configureCell(song)
            cell.setSong(song)
            return cell
        }
        
        return SongCell()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (mediaItems?.count)!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: SongCell? = tableView.cellForRowAtIndexPath(indexPath) as? SongCell
        
//        cell?.createWavOfSelectedSong()
    }


}

