//
//  EditHandlers.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech


extension Controller {
    
    func autoTrimVideo(){
        guard let url = videoURL else { return }
        guard let duration = trimDuration else { return }
        let asset = AVAsset(url: url)
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        self.assetDuration = length
        
        if duration > length {
            endTime = length
        } else {
            endTime = duration
        }
        
        
        recognizeFile()
    }
    
    func trimAndComposition(){
        guard let url = videoURL else { return }
        let asset = AVAsset(url: url)
    
        let mixComposition = AVMutableComposition()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
                                                      of: asset.tracks(withMediaType: AVMediaTypeVideo)[0] ,
                                                      at: kCMTimeZero)
        } catch _ {
            print("Failed to load first track")
        }
        
        
        let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
                                           of: asset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                           at: kCMTimeZero)
        } catch _ {
            print("Failed to load audio track")
        }
        
        let assetVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        // check for orientation
        var isVideoAssetPortrait = false
        
        let videoTransform = compositionVideoTrack.preferredTransform;
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait = true
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait = true
        }
        if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
            isVideoAssetPortrait = false
        }
        if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
            isVideoAssetPortrait = false
        }
        
        // change naturalsize
        var naturalSize: CGSize
        if(isVideoAssetPortrait){
            naturalSize = CGSize(width: compositionVideoTrack.naturalSize.height, height: compositionVideoTrack.naturalSize.width)
        } else {
            naturalSize = compositionVideoTrack.naturalSize
        }
        
        // 1 - Set up the text layer
        let subtitleText = CATextLayer()
        let myAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightMedium)]
        let string = NSAttributedString(string: stringToShow, attributes: myAttributes)
        subtitleText.string = string
        subtitleText.alignmentMode = kCAAlignmentCenter
        subtitleText.allowsFontSubpixelQuantization = true
        
        subtitleText.isWrapped = true
        let frameSetter = CTFramesetterCreateWithAttributedString(string)
        let range = CFRange(location: 0, length: string.length)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, nil, CGSize(width: naturalSize.width - 40, height: CGFloat.greatestFiniteMagnitude), nil)
        
        subtitleText.frame = CGRect(x: 20, y: 60, width: naturalSize.width - 40, height: size.height)
        subtitleText.contentsScale = UIScreen.main.scale
        
        
        let overlayLayer = CALayer()
        overlayLayer.addSublayer(subtitleText)
        overlayLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: subtitleText.frame.height + 80)
        overlayLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        overlayLayer.masksToBounds = true
        
        //sorts the layer in proper order
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        
        parentLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: naturalSize.width, height: naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)
        
        //create the composition and add the instructions to insert the layer:
        
        let videoComp = AVMutableVideoComposition()
        videoComp.renderSize = naturalSize
        videoComp.frameDuration = CMTimeMake(1, 30)
        videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        /// instruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: mixComposition.duration)
        
        let mixVideoTrack = mixComposition.tracks(withMediaType: AVMediaTypeVideo)[0]
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mixVideoTrack)
        instruction.layerInstructions = [layerInstruction]
        
        layerInstruction.setTransform(compositionVideoTrack.preferredTransform, at: kCMTimeZero)
        layerInstruction.setOpacity(0.0, at: asset.duration)
        
        videoComp.instructions = [instruction]
        
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            let name = randomText(length: 8, justLowerCase: false)
            outputURL = outputURL.appendingPathComponent("\(name).mp4")
        } catch let error {
            print(error)
        }
        
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        
        let startTime = CMTime(seconds: Double(self.startTime), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(self.endTime), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        exportSession.videoComposition = videoComp
        
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                self.exportMediaToLibrary(outputURL: outputURL)
            case .failed:
                print("failed \(exportSession.error)")
            case .cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
                
            }
        }
    }
    
    func exportMediaToLibrary(outputURL: URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { saved, error in
            if saved {
                if !self.lastVideo{
                    self.startTime = self.startTime + self.trimDuration!
                    self.endTime = self.endTime + self.trimDuration!
                    
                    if self.endTime > self.assetDuration! {
                        self.endTime = self.assetDuration!
                        self.recognizeFile()
                        self.lastVideo = true
                    }
                    
                    if !self.lastVideo{
                        self.recognizeFile()
                    }
                }
                
            }
        }
    }
    
    func recognizeFile() {
        guard let video = videoURL else { return }
        let asset = AVAsset(url: video)
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        
        var outputURL = documentDirectory.appendingPathComponent("transcriptions")
        
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).mp4")
        } catch let error {
            print(error)
        }
        
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeAppleM4A
        let startTime = CMTime(seconds: Double(self.startTime), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(self.endTime), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                print("outputurl \(outputURL)")
                self.speechTranscript(url: outputURL)
            case .failed:
                print("failed \(exportSession.error)")
                
            case .cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
                
            }
        }
    }
    
    func speechTranscript(url: URL) {
        guard let recognizer = SFSpeechRecognizer() else {
            print("Recognizer not supported")
            return
        }
        if !recognizer.isAvailable {
            print("Recognizer not available")
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { (result, error) in
            
            guard let result = result else {
                // Recognition failed, so check error for details and handle it
                print("Recognition failed")
                return
            }
            if result.isFinal {
                self.stringToShow = result.bestTranscription.formattedString
                print(self.stringToShow)
                self.trimAndComposition()
                
            }
        }}
}

