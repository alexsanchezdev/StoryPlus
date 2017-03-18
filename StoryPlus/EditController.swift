//
//  EditController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 16/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech

class EditController: UIViewController {
    
    var videoURL: URL?
    var trimDuration: Float?
    var stringToShow = ""
    var startTime: Float = 0
    var endTime: Float = 0
    var first = true
    
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
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightRegular)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "Esto es una prueba a ver que tal funciona cogiendo el CALayer el problema es que no se porque no aparece en el otro lado"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            print(authStatus)
        }
        setupViews()
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
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: trimButton.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
        
        

    }
    
    func handleOptions(){
        let optionsMenu = UIAlertController()
        //let optionsMenu = UIAlertController(title: NSLocalizedString("MenuTitle", comment: "This is the message that will be shown on top of the alert controller"), message: nil, preferredStyle: .actionSheet)
        let showAutotrim = UIAlertAction(title: "Test", style: .default, handler: {(action) in
            self.trimDuration = 15
            self.autoTrimVideo()
        })
        
        let cancelOptions = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        optionsMenu.addAction(showAutotrim)
        optionsMenu.addAction(cancelOptions)
        
        present(optionsMenu, animated: true, completion: nil)
    }

    
    
    
    
    

}
