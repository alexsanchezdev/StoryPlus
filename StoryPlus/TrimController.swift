//
//  TrimController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 19/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftSpinner
import AVFoundation
import Photos
import Firebase

let kBannerAdUnitID = "ca-app-pub-7788951705227269/3470372435"
let kInterstitialAdUnitID = "ca-app-pub-7788951705227269/8384923233"

class TrimController: UIViewController, GADInterstitialDelegate{
    
    var interstitial: GADInterstitial!

    var videoURL: URL?
    var trimDuration: Float?
    var assetDuration: Float?
    var startTime: Float = 0
    var endTime: Float = 0
    var timer: Timer!
    var currentVideo: Float = 1.0
    var numberOfVideos: Float = 0.0
    var progress: Double = 0.0
    
    
    let videoThumbnail: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var trimButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Autotrim video", for: .normal)
        button.addTarget(self, action: #selector(handleOptions), for: .touchUpInside)
        return button
    }()
    
    let bannerView: GADBannerView = {
        let banner = GADBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        return banner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.bannerView.adUnitID = kBannerAdUnitID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        self.interstitial = createAndLoadInterstitial()
    
        //UnityAds.initialize("1352658", delegate: self, testMode: true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
            SwiftSpinner.hide()
        })
        SwiftSpinner.show("Analyzing...")
        setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(videoThumbnail)
        videoThumbnail.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        videoThumbnail.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/16).isActive = true
        videoThumbnail.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        videoThumbnail.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(trimButton)
        trimButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trimButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        trimButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        trimButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 72).isActive = true
        
        view.addSubview(bannerView)
        bannerView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func handleAutoTrim(){
        
        if interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        } else {
            detectAssetLenght()
        }
        
    }
    
    func detectAssetLenght(){
        // Get video url and trim/parts duration from previous controller
        guard let url = videoURL else { return }
        guard let duration = trimDuration else { return }
        
        // Get asset from url and detect is total length
        let asset = AVAsset(url: url)
        self.assetDuration = Float(asset.duration.value) / Float(asset.duration.timescale)
        
        if let length = self.assetDuration {
            self.numberOfVideos = length / duration
            if (length.truncatingRemainder(dividingBy: duration)) > 0 {
                self.numberOfVideos += 1
            }
            // Detect if trim duration is longer than asset duration or not
            if duration > length {
                self.endTime = length
            } else {
                self.endTime = duration
            }
        }
        
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: true)
        createComposition(asset: asset)
        
    }
    
    func createComposition(asset: AVAsset){
        // Create composition for video and audio mix and orientation fix
        let mixComposition = AVMutableComposition()
        
        // Add video to composition
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo,preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
                                                      of: asset.tracks(withMediaType: AVMediaTypeVideo)[0] ,
                                                      at: kCMTimeZero)
        } catch _ {
            print("Failed to load first track")
        }
        
        // Add audio to composition
        let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration),
                                           of: asset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                           at: kCMTimeZero)
        } catch _ {
            print("Failed to load audio track")
        }
        
        // Set preferred transform for video so it stays as original asset
        let assetVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        trimVideo(video: mixComposition) { (url) in
            if url.absoluteString != "" {
                self.exportMediaToLibrary(mediaURL: url)
            }
            
        }
        
    }
    
    func trimVideo(video: AVMutableComposition, completion: @escaping (_ result: URL) -> Void) {
        let manager = FileManager.default
        if let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                let name = randomText(length: 8, justLowerCase: false)
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
            } catch let error {
                print(error)
            }
            
            _ = try? manager.removeItem(at: outputURL)
            
            if let exportSession = AVAssetExportSession(asset: video, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileTypeQuickTimeMovie
                
                if let length = self.assetDuration {
                    if self.endTime > length {
                        self.endTime = length
                    }
                    
                    let startTime = CMTime(seconds: Double(self.startTime), preferredTimescale: 1000)
                    let endTime = CMTime(seconds: Double(self.endTime), preferredTimescale: 1000)
                    let timeRange = CMTimeRange(start: startTime, end: endTime)
                    exportSession.timeRange = timeRange
                    
                    exportSession.exportAsynchronously{
                        switch exportSession.status {
                        case .completed:
                            completion(outputURL)
                            print("Trimed video")
                        case .failed:
                            print("failed \(exportSession.error)")
                        case .cancelled:
                            print("cancelled \(exportSession.error)")
                            
                        default: break
                            
                        }
                    }
                }
                
            }
        }
        
    }
    
    func exportMediaToLibrary(mediaURL: URL){
        guard let url = videoURL else { return }
        let asset = AVAsset(url: url)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: mediaURL)
        }) { saved, error in
            if saved {
                if let length = self.assetDuration {
                    if self.endTime < length {
                        if let trim = self.trimDuration {
                            self.startTime = self.startTime + trim
                            self.endTime = self.endTime + trim
                            self.currentVideo += 1.0
                            self.progress = Double(self.currentVideo / self.numberOfVideos)
                            print("Progress is: \(self.progress)")
                            self.createComposition(asset: asset)
                        }
                    } else {
                        self.progress = 1.0
                    }
                }
            }
        }
    }
    
    func handleOptions(){
        let optionsMenu = UIAlertController()
        //let optionsMenu = UIAlertController(title: NSLocalizedString("MenuTitle", comment: "This is the message that will be shown on top of the alert controller"), message: nil, preferredStyle: .actionSheet)
        let showAutotrim = UIAlertAction(title: "Test", style: .default, handler: {(action) in
            self.trimDuration = 15
            self.handleAutoTrim()
        })
        
        let cancelOptions = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        optionsMenu.addAction(showAutotrim)
        optionsMenu.addAction(cancelOptions)
        
        present(optionsMenu, animated: true, completion: nil)
    }
    
//    func unityAdsReady(_ placementId: String) {
//        SwiftSpinner.hide()
//        timer.invalidate()
//    }
//    
//    func unityAdsDidStart(_ placementId: String) {
//        
//    }
//    
//    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
//        SwiftSpinner.show("Analysis error").addTapHandler({
//            SwiftSpinner.hide()
//        }, subtitle: "Try again")
//    }
//    
//    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
//        if state == .completed {
//            print("Ads completed")
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
//                self.detectAssetLenght()
//            })
//            
//        } else if state == .skipped {
//            print("Ads skipped")
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
//                self.detectAssetLenght()
//            })
//        } else if state == .error {
//            print("Ads error")
//        }
//        
//    }
    
    func timerFire(_ timer: Timer) {
        SwiftSpinner.show(progress: progress, title: "Exporting... \(Int(progress*100))%")
        if progress >= 1.0 {
            timer.invalidate()
            SwiftSpinner.show(duration: 2.0, title: "Done!", animated: false)
            self.numberOfVideos = 0.0
            self.currentVideo = 0.0
            self.endTime = 0.0
            self.startTime = 0.0
            self.progress = 0.0
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial =
            GADInterstitial(adUnitID: kInterstitialAdUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        timer.invalidate()
        SwiftSpinner.hide()
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        detectAssetLenght()
    }
    
}
