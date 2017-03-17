//
//  TrimTranscriptController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import Speech


class TrimTranscriptController: UIViewController {
    
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            print(authStatus)
        }
    }
    
    func recognizeFile() {
        guard let video = videoURL else { return }
        let asset = AVAsset(url: video)
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        
        var outputURL = documentDirectory.appendingPathComponent("StoryPlus")
        
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("transcript.mp4")
        } catch let error {
            print(error)
        }
        
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeAppleM4A
        exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
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
    
    func speechTranscript(url: URL){
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
                return
            }
            if result.isFinal {
                _ = result.bestTranscription.formattedString
            }
        }}
    
}
