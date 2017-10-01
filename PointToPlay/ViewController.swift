//
//  ViewController.swift
//  PointToPlay
//
//  Created by Vassilis Vassileiades on 26/09/2017.
//  Copyright © 2017 vasvass corp. All rights reserved.
//

import UIKit
import MobileCoreServices
import Vision
import CoreML
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var objectLabel: UILabel!
    @IBOutlet var startButton: UILabel!
    @IBOutlet var skipButton: UILabel!
    @IBOutlet var topView: UILabel!
    @IBOutlet var bottomView: UILabel!
    
    var cameraLayer: CALayer!
    var gameTimer: Timer!
    var timeRemaining = 60
    var currentScore = 0
    var highScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
     viewSetup()
     cameraSetup()
    }
      func viewSetup() {
            let backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
            topView.backgroundColor = backgroundColor
            bottomView.backgroundColor = backgroundColor
            scoreLabel.text = "0" 
        }
        
        func cameraSetup() {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
            let input = try! AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
            
            cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(cameraLayer)
            cameraLayer.frame = view.bounds
            
            view.bringSubview(toFront:topView)
            view.bringSubview(toFront: bottomView)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "buffer delegate"))
            videoOutput.recommendedVideoSettings(forVideoCodecType: .jpeg, assetWriterOutputFileType: .mp4)
            
            captureSession.addOutput(videoOutput)
            captureSession.sessionPreset = .high
            captureSession.stopRunning()
    }
    
    func predict(image: CGImage) {
        let model = try! VNCoreMLModel (for: Inceptionv3().model)
        let request = VNCoreMLRequest(model: model, completionHandler: results)
        let handler = VNSequenceRequestHandler()
        try! handler.perform([request], on: image)
    }
    
    func results(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            print("No results found")
            return
        }
        guard results.count ! = 0 else {
            print("No result found")
            return
        }
        let highestConfidenceResult = results.first!
        let identifier = highestConfidenceResult.identifier.contains(",") ? String(describing: highestConfidenceResult.identifier.split(separator: ",").first!) : highestConfidenceResult.identifier
        
        if identifier == objectLabel.text! {
            currentScore += 1
            //nextobject()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


 }

