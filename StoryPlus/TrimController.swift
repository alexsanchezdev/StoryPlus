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

let kBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-7788951705227269/3470372435"
let kInterstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"//"ca-app-pub-7788951705227269/8384923233"

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
    var isVideoRecording = false
    var isSaved = false
    var videoURLs = [URL]()
    var transcriptionsString = [String]()
    var transcriptionsTimestamp: [[TimeInterval]] = Array(repeating: [TimeInterval](), count: 1)
    var type = String()
    var thumbnails = [UIImage]()
    
    
    let bannerView: GADBannerView = {
        let banner = GADBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        return banner
    }()
    
    let videoThumbnail: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        //image.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        image.contentMode = .scaleAspectFit
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.lightGray.cgColor
        return image
    }()
    
    lazy var trimButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("AUTOTRIM & EXPORT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        button.addTarget(self, action: #selector(trimOptions), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(r: 245, g: 45, b: 85, a: 1)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var transcriptButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("AUTOTRIM & TRANSCRIPT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        button.addTarget(self, action: #selector(transcriptOptions), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(r: 88, g: 86, b: 214, a: 1)//rgb(46, 204, 113)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    lazy var translateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("AUTOTRIM & TRANSLATE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        button.addTarget(self, action: #selector(transcriptOptions), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(r: 0, g: 122, b: 255, a: 1)//rgb(155, 89, 182)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    
    
    let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = UIColor.white
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        self.bannerView.adUnitID = kBannerAdUnitID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        let button = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        navigationItem.leftBarButtonItem = button
        
        if isVideoRecording {
            let button = UIBarButtonItem(image: UIImage(named: "download")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(saveVideo))
            navigationItem.rightBarButtonItem = button
        }
        self.interstitial = createAndLoadInterstitial()
       
        //UnityAds.initialize("1352658", delegate: self, testMode: true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
            SwiftSpinner.hide()
        })
        SwiftSpinner.show("Analyzing...")
        setupViews()
        
    }
    
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(translateButton)
        translateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        translateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        translateButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        translateButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(transcriptButton)
        transcriptButton.bottomAnchor.constraint(equalTo: translateButton.topAnchor).isActive = true
        transcriptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transcriptButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        transcriptButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(trimButton)
        trimButton.bottomAnchor.constraint(equalTo: transcriptButton.topAnchor).isActive = true
        trimButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trimButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        trimButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        
        
        view.addSubview(videoThumbnail)
        videoThumbnail.topAnchor.constraint(equalTo: view.topAnchor, constant: -1).isActive = true
        //videoThumbnail.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/16).isActive = true
        videoThumbnail.bottomAnchor.constraint(equalTo: trimButton.topAnchor).isActive = true
        videoThumbnail.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 2).isActive = true
        videoThumbnail.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
        view.addSubview(bannerView)
        bannerView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bannerView.bottomAnchor.constraint(equalTo: trimButton.topAnchor).isActive = true
        
        
        
        
        
        
        
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        
        
//        blurEffectView.addSubview(pickerView)
//        pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        pickerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        pickerView.heightAnchor.constraint(equalToConstant: 248).isActive = true
        
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
    
//    func showTranscriptController(){
//        let transcriptController = TranscriptController()
//        self.navigationController?.pushViewController(transcriptController, animated: true)
//    }
    
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
