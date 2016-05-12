//
//  LMAudioPlayer.swift
//  Song Morph
//
//  Created by Luke Morse on 5/8/16.
//  Copyright © 2016 Luke Morse. All rights reserved.
//

import Foundation
import MediaPlayer
import AudioToolbox
import AVFoundation
import OpenAL

class LMAudioPlayer: NSObject, NSStreamDelegate {
    
    var audioFileStreamID: AudioFileStreamID = nil
    
    let outputSettings: [String:Int] =
        [ AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVLinearPCMIsBigEndianKey: 0,
          AVLinearPCMIsFloatKey: 0,
          AVLinearPCMBitDepthKey: 16,
          AVLinearPCMIsNonInterleaved: 0]
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        if eventCode == NSStreamEvent.HasBytesAvailable {
            // handle incoming data
        } else if (eventCode == NSStreamEvent.EndEncountered) {
            // notify application that stream has ended
        } else if (eventCode == NSStreamEvent.ErrorOccurred) {
            // notify application that stream has encountered and error
        }
    }
    
    func openAudioStream() {
        
        var clientData = UnsafeMutablePointer<Void>(unsafeAddressOf(self))
        let listenerProc: AudioFileStream_PropertyListenerProc()
        var packetsProc : AudioFileStream_PacketsProc
//        var audioFileTypyeId : AudioFileTypeID = 0
        
        AudioFileStreamOpen(&clientData,
                            listenerProc,
                            packetsProc,
                            0,
                            &audioFileStreamID)
        
    }
    
    
    
    func createWavOfSelectedSong(song:MPMediaItem) {
        
        if let songUrl = song.assetURL {
            let asset = AVURLAsset(URL: songUrl)
            
            let outputStream = NSOutputStream(toMemory: ())
            outputStream.delegate = self
            
            let inputStream = NSInputStream()
            inputStream.delegate = self
            
            let currentRunLoop = NSRunLoop()
            outputStream.scheduleInRunLoop(currentRunLoop, forMode: NSDefaultRunLoopMode)
            inputStream.scheduleInRunLoop(currentRunLoop, forMode: NSDefaultRunLoopMode)
            outputStream.open()
            inputStream.open()
            
            do {
                let reader = try AVAssetReader(asset: asset)
                let track = asset.tracksWithMediaType(AVMediaTypeAudio)[0]
                let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
                reader.addOutput(output)
                reader.startReading()
                let sampleBuffer = output.copyNextSampleBuffer()
                
                var audioBufferList = AudioBufferList()
                let blockBuffer: UnsafeMutablePointer<CMBlockBuffer?> = nil
                
                
                CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer!, nil, &audioBufferList, sizeof(AudioBufferList), nil, nil, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, blockBuffer);
                
                
                let abl = UnsafeMutableAudioBufferListPointer(&audioBufferList)
                
                for audioBuffer in abl {
                    
                    //                    memset(audioBuffer.mData, 0, Int(audioBuffer.mDataByteSize))
                    
                    outputStream.write(UnsafePointer<UInt8>(audioBuffer.mData), maxLength: Int(audioBuffer.mDataByteSize))
                    
                    
                }
                
                //                while outputStream.hasSpaceAvailable {
                //
                //
                //
                //                }
                
                
                
                
                
                
                //                var x: UInt32 = 0
                //                while x < audioBufferList.mNumberBuffers {
                //                    let abl = UnsafeMutableAudioBufferListPointer(UnsafeMutablePointer<AudioBufferList>(nil))
                //                    let audioBuffer: AudioBuffer = abl.
                //                    //                    let audioStream = audioBuffer
                //                    x += 1
                //                }
                
                
                
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
            
            print(song.title)
            
        }
        
    }
    
}

