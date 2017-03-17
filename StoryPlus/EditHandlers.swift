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

extension EditController {
    
    func autoTrimVideo(){
        guard let url = videoURL else { return }
        guard let duration = trimDuration else { return }
        let asset = AVAsset(url: url)
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        let videosFromSeconds = length / duration
        
        let reminder = length.truncatingRemainder(dividingBy: duration)
        var numberOfVideos: Int
        
        if reminder != 0 {
            numberOfVideos = Int(videosFromSeconds) + 1
            print("number of videos: \(numberOfVideos)")
        } else {
            numberOfVideos = Int(videosFromSeconds)
            print("number of videos: \(numberOfVideos)")
        }
        
        let mixComposition = AVMutableComposition()
        
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
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
        
        if let assetVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).last {
            if let compositionVideoTrack = mixComposition.tracks(withMediaType: AVMediaTypeVideo).last {
                compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
                
                
                
                let mainInstruction = AVMutableVideoCompositionInstruction()
                mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
                
                let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetVideoTrack)
                
                mainInstruction.layerInstructions = [videoLayerInstruction]
                
                let mainCompositionInst = AVMutableVideoComposition()
                
                mainCompositionInst.renderSize = CGSize(width: mixComposition.naturalSize.width, height: mixComposition.naturalSize.height)
                mainCompositionInst.instructions = [mainInstruction]
                mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
                
                let subtitleText = CATextLayer()
                subtitleText.fontSize = 16
                subtitleText.frame = CGRect(x: 0, y: 0, width: mixComposition.naturalSize.width, height: 100)
                subtitleText.string = "¡Hola Mama!"
                subtitleText.alignmentMode = kCAAlignmentCenter
                subtitleText.foregroundColor = UIColor.white.cgColor
                subtitleText.backgroundColor = UIColor.black.cgColor
                
                let overlayLayer = CALayer()
                overlayLayer.addSublayer(subtitleText)
                overlayLayer.frame = CGRect(x: 0, y: 0, width: mixComposition.naturalSize.width, height: mixComposition.naturalSize.height)
                overlayLayer.masksToBounds = true
                
                let parentLayer = CALayer()
                let videoLayer = CALayer()
                parentLayer.frame = CGRect(x: 0, y: 0, width: mixComposition.naturalSize.width, height: mixComposition.naturalSize.height)
                videoLayer.frame = CGRect(x: 0, y: 0, width: mixComposition.naturalSize.width, height: mixComposition.naturalSize.height)
                parentLayer.addSublayer(videoLayer)
                parentLayer.addSublayer(overlayLayer)
                
                mainCompositionInst.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
                
                var startTime: Float = 0
                var endTime = duration
                
                for index in 1...numberOfVideos {
                    if index == numberOfVideos && reminder != 0{
                        self.trimVideo(asset: mixComposition, composition: mainCompositionInst, start: startTime, end: startTime + reminder)
                    } else {
                        self.trimVideo(asset: mixComposition, composition: mainCompositionInst, start: startTime, end: endTime)
                        startTime = endTime
                        endTime = endTime + duration
                    }
                    
                }
                
            }
            
        }
        
        
        
//        let mainInstruction = AVMutableVideoCompositionInstruction()
//        mainInstruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
//        
//        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
//        
//        mainInstruction.layerInstructions = [videoLayerInstruction]
//        
//        let mainCompositionInst = AVMutableVideoComposition()
//        
//        mainCompositionInst.renderSize = naturalSize!
//        mainCompositionInst.instructions = [mainInstruction]
//        mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
//        
//        let subtitleText = CATextLayer()
//        subtitleText.fontSize = 16
//        subtitleText.frame = CGRect(x: 0, y: 0, width: (naturalSize?.width)!, height: 100)
//        subtitleText.string = "¡Hola Mama!"
//        subtitleText.alignmentMode = kCAAlignmentCenter
//        subtitleText.foregroundColor = UIColor.white.cgColor
//        subtitleText.backgroundColor = UIColor.black.cgColor
//        
//        let overlayLayer = CALayer()
//        overlayLayer.addSublayer(subtitleText)
//        overlayLayer.frame = CGRect(x: 0, y: 0, width: (naturalSize?.width)!, height: (naturalSize?.height)!)
//        overlayLayer.masksToBounds = true
//        
//        let parentLayer = CALayer()
//        let videoLayer = CALayer()
//        parentLayer.frame = CGRect(x: 0, y: 0, width: (naturalSize?.width)!, height: (naturalSize?.height)!)
//        videoLayer.frame = CGRect(x: 0, y: 0, width: (naturalSize?.width)!, height: (naturalSize?.height)!)
//        parentLayer.addSublayer(videoLayer)
//        parentLayer.addSublayer(overlayLayer)
//        
//        mainCompositionInst.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
    }
    func trimVideo(asset: AVMutableComposition, composition: AVMutableVideoComposition, start: Float, end: Float){
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
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
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        
        let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        exportSession.shouldOptimizeForNetworkUse = true
        //exportSession.videoComposition = composition
        
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                }) { saved, error in
                    if saved {
                        self.semaphore.signal()
                    }
                }
                
            case .failed:
                print("failed \(exportSession.error)")
                
            case .cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
                
            }
        }
        
    }
    func randomText(length: Int, justLowerCase: Bool) -> String {
        var text = ""
        for _ in 1...length {
            var decValue = 0  // ascii decimal value of a character
            var charType = 3  // default is lowercase
            if justLowerCase == false {
                // randomize the character type
                charType =  Int(arc4random_uniform(4))
            }
            switch charType {
            case 1:  // digit: random Int between 48 and 57
                decValue = Int(arc4random_uniform(10)) + 48
            case 2:  // uppercase letter
                decValue = Int(arc4random_uniform(26)) + 65
            case 3:  // lowercase letter
                decValue = Int(arc4random_uniform(26)) + 97
            default:  // space character
                decValue = 32
            }
            // get ASCII character from random decimal value
            let char = String(describing: UnicodeScalar(decValue))
            text = text + char
            // remove double spaces
            text = text.replacingOccurrences(of: "  ", with: " ")
        }
        return text
    }
}

