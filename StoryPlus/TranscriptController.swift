//
//  TrimTranscriptController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 17/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Speech
import Photos
import SwiftSpinner

class TranscriptController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var languageCode = ""
    let reuseIdentifier = "cell"
    var thumbnails: [UIImage]?
    var videoURLs: [URL]?
    var transcriptions = [String]()
    var currentVideoIndex = 0
    var currentVideo: Float = 1.0
    var progress = 0.0
    
    
    lazy var selectLanguage: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LANGUAGE: By default", for: .normal)
        button.addTarget(self, action: #selector(showLanguagesController), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        
        button.backgroundColor = UIColor.rgb(r: 88, g: 86, b: 214, a: 1)//rgb(52, 152, 219)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var transcriptVideo: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRANSCRIPT VIDEOS", for: .normal)
        button.addTarget(self, action: #selector(transcriptVideos), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        button.backgroundColor = UIColor.rgb(r: 245, g: 45, b: 85, a: 1)//rgb(52, 152, 219)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var videosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let reminder = self.view.frame.width.truncatingRemainder(dividingBy: 4)
        let size = (self.view.frame.width / 4) - (reminder / 4)
        
        layout.itemSize = CGSize(width: size, height: size)
        layout.sectionInset = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(VideoCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = UIColor.white
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        return collection
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        
        createEmptyStringArrayForVideos()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Language code: " + languageCode)
        
        for i in 0..<transcriptions.count {
            print("First video: \(transcriptions[i])")
        }
        
    }
    
    func setupViews(){
        
        view.addSubview(transcriptVideo)
        transcriptVideo.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        transcriptVideo.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        transcriptVideo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transcriptVideo.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(selectLanguage)
        selectLanguage.bottomAnchor.constraint(equalTo: transcriptVideo.topAnchor).isActive = true
        selectLanguage.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        selectLanguage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectLanguage.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(videosCollectionView)
        videosCollectionView.bottomAnchor.constraint(equalTo: selectLanguage.topAnchor).isActive = true
        videosCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        videosCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        videosCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    func showLanguagesController(){
        let languagesController = LanguagesController()
        languagesController.transcriptController = self
        let navigation = UINavigationController(rootViewController: languagesController)
        self.present(navigation, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = thumbnails?.count {
            return count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cell.videoImageView.image = thumbnails?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //if let url = videoURLs?[indexPath.row] {
            //playVideo(url: url)
        //}
        showEditControllerFor(index: indexPath.row)
    }
    
    func playVideo(url: URL){
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
//    func recognizeFile() {
//        guard let video = videoURL else { return }
//        let asset = AVAsset(url: video)
//        let manager = FileManager.default
//        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
//        
//        var outputURL = documentDirectory.appendingPathComponent("transcriptions")
//        
//        do {
//            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
//            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).mp4")
//        } catch let error {
//            print(error)
//        }
//        
//        _ = try? manager.removeItem(at: outputURL)
//        
//        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
//        exportSession.outputURL = outputURL
//        exportSession.outputFileType = AVFileTypeAppleM4A
//        
//        if let length = self.assetDuration {
//            if self.endTime > length {
//                self.endTime = length
//            }
//            
//            let startTime = CMTime(seconds: Double(self.startTime), preferredTimescale: 1000)
//            let endTime = CMTime(seconds: Double(self.endTime), preferredTimescale: 1000)
//            let timeRange = CMTimeRange(start: startTime, end: endTime)
//            exportSession.timeRange = timeRange
//            
//            exportSession.exportAsynchronously{
//                switch exportSession.status {
//                case .completed:
//                    print("outputurl \(outputURL)")
//                    self.speechTranscript(url: outputURL)
//                case .failed:
//                    print("failed \(exportSession.error)")
//                    
//                case .cancelled:
//                    print("cancelled \(exportSession.error)")
//                    
//                default: break
//                    
//                }
//            }
//        }
//        
//    }
    
    func speechTranscript(url: URL) {
        if languageCode == "" {
            if let recognizer = SFSpeechRecognizer() {
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
                        print(result.bestTranscription.formattedString)
                    }
                }
            }
        } else {
            let locale = Locale(identifier: languageCode)
            if let recognizer = SFSpeechRecognizer(locale: locale) {
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
                        print(result.bestTranscription.formattedString)
                    }
                }
            }
        }
        
    }
    
    func showEditControllerFor(index: Int){
        let editController = EditController()
        editController.videoURL = self.videoURLs?[index]
        editController.title = "Video #\(index + 1)"
        editController.transcriptController = self
        editController.videoIndex = index
        self.navigationController?.pushViewController(editController, animated: true)
    }
    
    func createEmptyStringArrayForVideos(){
        transcriptions.removeAll()
        if let array = videoURLs {
            for _ in 0..<array.count {
                transcriptions.append("")
            }
        }
    }
    
    func transcriptVideos(){
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.exportFire), userInfo: nil, repeats: true)
        detectAssetLenght(forIndex: 0)
    }
    
    func detectAssetLenght(forIndex: Int) {
        
        guard let url = videoURLs?[forIndex] else { return }
        let asset = AVAsset(url: url)
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)

        trimAndComposition(asset: asset, start: 0.0, end: length)
    }
    
    func trimAndComposition(asset: AVAsset, start: Float, end: Float){
        
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
        let string = NSAttributedString(string: transcriptions[currentVideoIndex], attributes: myAttributes)
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
            
            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).mp4")
        } catch let error {
            print(error)
        }
        
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        
        let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
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
                let endOfArray = self.transcriptions.count - 1
                self.currentVideoIndex += 1
                if (self.currentVideoIndex <= endOfArray) {
                    self.currentVideo += 1.0
                    self.progress = Double(self.currentVideo / Float(self.transcriptions.count))
                    self.detectAssetLenght(forIndex: self.currentVideoIndex)
                } else {
                    self.progress = 1.0
                }
            }
        }
    }
    
    func exportFire(_ timer: Timer) {
        
        SwiftSpinner.show(progress: progress, title: "Exporting... \(Int(progress*100))%")
        if progress >= 1.0 {
            timer.invalidate()
            SwiftSpinner.show(duration: 2.0, title: "Exported to camera roll.", animated: false)
            self.currentVideo = 1.0
            self.progress = 0.0
        }
    }
    

}
