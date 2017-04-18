//
//  EditController.swift
//  StoryPlus
//
//  Created by Alex Sanchez on 24/3/17.
//  Copyright © 2017 Alex Sanchez. All rights reserved.
//

import UIKit
import AVFoundation

class EditController: UIViewController, UITextViewDelegate {
    
    var videoIndex: Int!
    var videoURL: URL!
    var isPlaying = false
    var player: AVPlayer!
    var transcriptController: TranscriptController?
    
    let transcriptTextView: UITextView = {
        let textview = UITextView()
        textview.translatesAutoresizingMaskIntoConstraints = false
        textview.isScrollEnabled = true
        
        return textview
    }()
    
    lazy var playControl: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playStopControl)))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        player = AVPlayer(url: videoURL)
        transcriptTextView.delegate = self
        transcriptTextView.text = transcriptController?.transcriptions[videoIndex]
        setupViews()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        transcriptController?.transcriptions[videoIndex] = textView.text
    }
    
    func setupViews(){
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: (view.bounds.width * (9/16)))
        playerLayer.backgroundColor = UIColor.black.cgColor
        view.layer.addSublayer(playerLayer)
        
        view.addSubview(playControl)
        playControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        playControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playControl.bottomAnchor.constraint(equalTo: view.topAnchor, constant: playerLayer.frame.height).isActive = true
        
        view.addSubview(transcriptTextView)
        transcriptTextView.topAnchor.constraint(equalTo: playControl.bottomAnchor).isActive = true
        transcriptTextView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        transcriptTextView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        transcriptTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    
    }
    

    
    func playStopControl(){
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
}
