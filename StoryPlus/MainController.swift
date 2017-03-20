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
    
    let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var recordImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "camera")
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRecordVideo)))
        image.isUserInteractionEnabled = true
        image.contentMode = UIViewContentMode.center
        return image
    }()
    
    lazy var importImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "folder")
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImportVideo)))
        image.isUserInteractionEnabled = true
        image.contentMode = UIViewContentMode.center
        return image
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVideoRecording = false
    }
    
    
    func setupViews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(mainView)
        mainView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mainView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        mainView.addSubview(recordImage)
        recordImage.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        recordImage.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        recordImage.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        recordImage.bottomAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        
        mainView.addSubview(importImage)
        importImage.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
        importImage.topAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        importImage.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
        importImage.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
    }
    
    func handleImportVideo(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func handleRecordVideo(){
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = .typeHigh
        picker.cameraDevice = .front
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            _ = NSData(contentsOf: videoURL)
                self.dismiss(animated: true, completion: {
                    let trimController = TrimController()
                    trimController.videoThumbnail.image = self.thumbnailForVideoAtURL(url: videoURL)
                    trimController.videoURL = videoURL
                    trimController.title = "Options"
                    self.navigationController?.pushViewController(trimController, animated: true)
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
}

