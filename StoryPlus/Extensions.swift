//
//  Extensions.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension AVAsset {
    func writeAudioTrack(to url: URL, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        do {
            let asset = try audioAsset()
            asset.write(to: url, success: success, failure: failure)
        } catch {
            failure(error)
        }
    }
    
    private func write(to url: URL, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {            
            return
        }
        
        exportSession.outputFileType = AVFileTypeAppleM4A
        exportSession.outputURL = url
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                success()
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                print("Export asyncrhonosly failure")
            }
        }
    }
    
    private func audioAsset() throws -> AVAsset {
        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: AVMediaTypeAudio)
        
        for track in audioTracks {
            let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try compositionTrack.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            } catch {
                throw error
            }
            compositionTrack.preferredTransform = track.preferredTransform
        }
        
        return composition
    }
}

extension UIViewController {

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

extension UIColor {
    
    static func rgb (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor{
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
}
