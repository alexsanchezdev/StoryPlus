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

class MainController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var mainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Seleccionar archivo", for: .normal)
        button.addTarget(self, action: #selector(handleSelectVideo), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    func setupViews(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(mainButton)
        mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mainButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        mainButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 72).isActive = true
        
    }
    
    func handleSelectVideo(){
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = .typeHigh
        
        self.present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            _ = NSData(contentsOf: videoURL)
            dismiss(animated: true, completion: {
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

