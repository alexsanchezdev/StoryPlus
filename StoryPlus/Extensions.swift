//
//  Extensions.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import Foundation
import AVFoundation

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
