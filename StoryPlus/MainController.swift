//
//  MainController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 16/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary
import Photos
import SwiftSpinner



class MainController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isVideoRecording = false
    
    lazy var deleteAds: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("DELETE ADS & SUPPORT DEVELOPER", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        //button.addTarget(self, action: #selector(trimOptions), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(r: 0, g: 122, b: 255, a: 1)//rgb(52, 152, 219)
        button.setTitleColor(UIColor.white, for: .normal)
        return button
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var recordView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.rgb(r: 255, g: 45, b: 85, a: 1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRecordVideo)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var importView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.rgb(r: 88, g: 86, b: 214, a: 1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImportVideo)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let recordImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "camera")
        image.tintColor = UIColor.white
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let importImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "folder")
        image.tintColor = UIColor.white
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let recordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "RECORD"
        label.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    let importLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "IMPORT"
        label.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightBold)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }()
    
    let recordActivity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true
        return activity
    }()
    
    let importActivity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.hidesWhenStopped = true
        return activity
    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordImage.isHidden = false
        recordActivity.stopAnimating()
        importImage.isHidden = false
        importActivity.stopAnimating()
    }

    func setupViews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(deleteAds)
        deleteAds.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        deleteAds.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteAds.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        deleteAds.heightAnchor.constraint(equalToConstant: 72).isActive = true
        
        view.addSubview(mainView)
        mainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mainView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mainView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: deleteAds.topAnchor).isActive = true

        mainView.addSubview(recordView)
        recordView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        recordView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        recordView.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        recordView.bottomAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        
        mainView.addSubview(importView)
        importView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        importView.topAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        importView.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        importView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        recordView.addSubview(recordImage)
        recordImage.centerXAnchor.constraint(equalTo: recordView.centerXAnchor).isActive = true
        recordImage.centerYAnchor.constraint(equalTo: recordView.centerYAnchor, constant: -20).isActive = true
        recordImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        recordImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        importView.addSubview(importImage)
        importImage.centerXAnchor.constraint(equalTo: importView.centerXAnchor).isActive = true
        importImage.centerYAnchor.constraint(equalTo: importView.centerYAnchor, constant: -20).isActive = true
        importImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        importImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        recordView.addSubview(recordLabel)
        recordLabel.topAnchor.constraint(equalTo: recordImage.bottomAnchor, constant: 20).isActive = true
        recordLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        recordLabel.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        recordLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        importView.addSubview(importLabel)
        importLabel.topAnchor.constraint(equalTo: importImage.bottomAnchor, constant: 20).isActive = true
        importLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        importLabel.widthAnchor.constraint(equalTo: mainView.widthAnchor).isActive = true
        importLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        recordView.addSubview(recordActivity)
        recordActivity.centerXAnchor.constraint(equalTo: recordImage.centerXAnchor).isActive = true
        recordActivity.centerYAnchor.constraint(equalTo: recordImage.centerYAnchor).isActive = true
        
        importView.addSubview(importActivity)
        importActivity.centerXAnchor.constraint(equalTo: importImage.centerXAnchor).isActive = true
        importActivity.centerYAnchor.constraint(equalTo: importImage.centerYAnchor).isActive = true
        
    }
    
    func handleImportVideo(){
        importImage.isHidden = true
        importActivity.startAnimating()
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        
        isVideoRecording = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func handleRecordVideo(){
        recordImage.isHidden = true
        recordActivity.startAnimating()
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = .typeHigh
        picker.cameraDevice = .front
        isVideoRecording = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            //_ = NSData(contentsOf: videoURL)
                self.dismiss(animated: true, completion: {
                    let trimController = TrimController()
                    trimController.videoThumbnail.image = self.thumbnailForVideoAtURL(url: videoURL)
                    trimController.videoURL = videoURL
                    trimController.isVideoRecording = self.isVideoRecording
                    trimController.title = "Options"
                    let navigation = UINavigationController(rootViewController: trimController)
                    self.present(navigation, animated: true, completion: nil)
                })
        }
    }
    
    private func thumbnailForVideoAtURL(url: URL) -> UIImage? {
        
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
            
        } catch {
            print("error")
            return nil
        }
    }
    
    func showBuyController(){
    
    }
}

