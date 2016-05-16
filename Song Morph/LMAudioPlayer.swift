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
    
    var currentSong: MPMediaItem!
    
    var inputStream: NSInputStream!
    
    var data: UnsafePointer<Void> = nil
    
    var basicDescription: AudioStreamBasicDescription!
    
    let audioQueue = AudioQueueRef()
    
    let outputSettings: [String:Int] =
        [ AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVLinearPCMIsBigEndianKey: 0,
          AVLinearPCMIsFloatKey: 0,
          AVLinearPCMBitDepthKey: 16,
          AVLinearPCMIsNonInterleaved: 0]
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        if eventCode == NSStreamEvent.HasBytesAvailable {
            // handle incoming data
            
            var buffer = [UInt8](count: 512, repeatedValue: 0)
            
            let length = UInt32(inputStream.read(&buffer, maxLength: 512))
            
            let flag = AudioFileStreamParseFlags(rawValue: 0)
            
            AudioFileStreamParseBytes(audioFileStreamID, length, data, flag)
            
        } else if (eventCode == NSStreamEvent.EndEncountered) {
            // notify application that stream has ended
        } else if (eventCode == NSStreamEvent.ErrorOccurred) {
            // notify application that stream has encountered and error
        }
    }
    
    func didChangeProperty(property: AudioFileStreamPropertyID, flags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
        
        if property == kAudioFileStreamProperty_ReadyToProducePackets {
            
            basicDescription = AudioStreamBasicDescription()
            var basicDescriptionSize = sizeofValue(basicDescription)
            
            var basicDescriptionSize32 = UInt32(basicDescriptionSize)
            
            AudioFileStreamGetProperty(audioFileStreamID, kAudioFileStreamProperty_DataFormat, &basicDescriptionSize32, &basicDescription)
            
            createAudioQueue()
        }
    }
    
    func didReceivePackets(inputData: UnsafePointer<Void>, packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>, numberOfPackets: UInt32, numberOfBytes: UInt32) {
        
        data = inputData
    }
    
    func createAudioQueue() {
        
//        var unsafe = UnsafePointer<AudioStreamBasicDescription>(basicDescription)
        
        var output = AudioQueueNewOutput(basicDescription, AudioQueueOutputCallback, data, nil, nil, 0, &audioQueue)
        
        
        
        
    }
    
    typealias AudioQueueOutputCallback = (UnsafeMutablePointer<Void>, AudioQueueRef, AudioQueueBufferRef) -> Void
    
    func openAudioStream() {
        
        if let songUrl = currentSong.assetURL {
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
                    
                    outputStream.write(UnsafePointer<UInt8>(audioBuffer.mData), maxLength: Int(audioBuffer.mDataByteSize))
                    
                    
                }
                
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
            
            print(currentSong.title)
            
        }
        
//        this is the stuff that was not in the old function...
        
        var contextObject: UnsafeMutablePointer<Void> = UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque())
        
        typealias AudioFileStream_PropertyListenerProc = @convention(c) (UnsafeMutablePointer<Void>, AudioFileStreamID, AudioFileStreamPropertyID, UnsafeMutablePointer<AudioFileStreamPropertyFlags>) -> Void
        
        let inPropertyListenerProc: AudioFileStream_PropertyListenerProc = {
            (inContext, streamID, inPropertyID, propertyFlags) -> Void in
            // this is the callback that gets called when there's a new property
            // probably log some of this stuff to start
            
            let mySelf = Unmanaged<LMAudioPlayer>.fromOpaque(COpaquePointer(inContext)).takeUnretainedValue()
            
            mySelf.didChangeProperty(inPropertyID, flags: propertyFlags)
            
        }
        
        typealias AudioFileStream_PacketsProc = @convention(c) (UnsafeMutablePointer<Void>, UInt32, UInt32, UnsafePointer<Void>, UnsafeMutablePointer<AudioStreamPacketDescription>) -> Void
        
        let inPacketsListener: AudioFileStream_PacketsProc = {
            (inContext, inNumberBytes, inNumberPackets, inInputData, inPacketDescriptions) -> Void in
            // this is the callback that gets called when there are audio data packets
            
            let mySelf = Unmanaged<LMAudioPlayer>.fromOpaque(COpaquePointer(inContext)).takeUnretainedValue()
            
            mySelf.didReceivePackets(inInputData, packetDescriptions: inPacketDescriptions, numberOfPackets: inNumberPackets, numberOfBytes: inNumberBytes)
            
        }
        
        // you can set this to something other than nil if you want to pass information to the callbacks in their inContext arguments
        //    let contextObject: UnsafeMutablePointer<Void> = nil
        
        
        let status = AudioFileStreamOpen(contextObject, inPropertyListenerProc, inPacketsListener, 0,&audioFileStreamID)
        
        print(status.description)
        
        
        
    }
    
    
}

