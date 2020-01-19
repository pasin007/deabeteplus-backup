//
//  ScanViewController.swift
//  deabeteplus
//
//  Created by Ji Ra on 1/12/2562 BE.
//  Copyright © 2562 Ji Ra. All rights reserved.
//

import UIKit

// camera
import AVKit

// ML
import Vision

class ScanViewController: UIViewController, BaseViewController, FoodDetailViewControllerDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var scanButton: UIButton!
    
    private var scanImage: UIImage? = nil
//    private let viewModel: ImageViewModel = ImageViewModel()
    private let viewModel: FoodViewModel = FoodViewModel()
    
    var foodImage: UIImage? = nil
    
    var statusScan: Bool = true {
        didSet {
//            scanButton.isHidden = statusScan
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setCamera()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusScan = true
//        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusScan = false
//        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        setCamera()
    }
}

extension ScanViewController {
    @IBAction func newScan() {
        statusScan = true
    }
    
    private func uploadImage(_ imageBuffer: CVPixelBuffer,_ name: String) {
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = convert(ciimage).rotate(radians: .pi/2)
        foodImage = image
        getFoodData(name)
    }
    
    
    // Convert CIImage to CGImage
    func convert(_ cmage:CIImage) -> UIImage
    {
         let context :CIContext = CIContext.init(options: nil)
         let cgImage: CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image: UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    
    private func getFoodData(_ name: String) {
        viewModel.getFood(name, onSuccess: { [weak self] (food) in
            Navigator.shared.showFoodDetailView(self, food: food)
        }) { (error) in
            
        }
    }
    

}

/// MARK : Camera
extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    private func setCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        //  ตั้งค่ากล้อง
        /// Set Input Image
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        /// Set Camera to BG
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.frame
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)

        
        /// Set Output image
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    
//        cameraView.layer.zPosition = 1
//        textLabel.layer.zPosition = 2
    }
    
    /// MARK : output image
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard statusScan else { return }
        
        // 1
        /// convert CMSampleBuffer to CVPixelBuffer
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                        
        // 2
        guard let model = try? VNCoreMLModel(for: Food101().model) else { return }
        
        // 3
        let request = VNCoreMLRequest(model: model) { [weak self] (finishedReq, err) in
            // 5
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                            
            guard let firstObservation = results.first else { return }
                            
            print("\(firstObservation.identifier) : \(firstObservation.confidence)")
            
            guard firstObservation.confidence > 0.8, firstObservation.identifier != "Table" else {
//                DispatchQueue.main.async {
//                    self?.textLabel.isHidden = true
//                }
                return
            }
            
            
            DispatchQueue.main.async {

//                if self?.textLabel.isHidden == true {
//                    self?.textLabel.isHidden = false
//                }
//
//                if self?.textLabel.text != firstObservation.identifier {
//                    self?.textLabel.text = firstObservation.identifier
//                }
                
                self?.statusScan = false
                self?.uploadImage(pixelBuffer,firstObservation.identifier)

            }
        }
        
        // 4
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
}
