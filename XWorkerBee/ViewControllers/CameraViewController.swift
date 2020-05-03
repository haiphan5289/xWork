//
//  CameraViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/9/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate{
    func receiveData(data: Data?)
}

class CameraViewController: UIViewController {
    
    @IBOutlet weak var btnCapture: UIButton!
    
    var captureSession: AVCaptureSession?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var captureButton: UIButton?
    var camDelegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupCaptureButton()
        startRuningCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            break
        case .notDetermined:
            break
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
            break
        default:
            break
        }

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                if (!videoGranted) {
                        print("don't allow")
                    self.alertPromptToAllowCameraAccessViaSetting()
                }
            })
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        let alert = UIAlertController(
            title: "Thông báo",
            message: "Vui lòng cài đặt cho phép ứng dụng truy cập camera của bạn",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: {(alert) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cài đặt", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func setupCaptureSession(){
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = .medium
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = frontCamera
    }
    
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession?.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            if #available(iOS 11.0, *) {
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],completionHandler: nil)
            } else {
                photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecJPEG])], completionHandler: nil)
            }
            captureSession?.addOutput(photoOutput!)
        }catch{
            print(error)
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func startRuningCaptureSession(){
        captureSession?.startRunning()
    }
    
    func setupCaptureButton(){
        //btnCapture!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
        //btnCapture!.layer.borderColor = UIColor.black.cgColor
        btnCapture!.layer.cornerRadius = Constant.BORDER_RADIUS
        btnCapture!.setTitle("Chấm công", for: .normal)
        //btnCapture!.setTitleColor(UIColor.black, for: .normal)
        //btnCapture!.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
    }
    
    @IBAction func btnCaptureAction(_ sender: Any) {
        Utils.loading(self.view, startAnimate: true)
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func btnActionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension CameraViewController: AVCapturePhotoCaptureDelegate{
   
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            camDelegate?.receiveData(data: imageData)
            self.dismiss(animated: true, completion: nil)
        }
        
//        let cgImage = photo.cgImageRepresentation()!.takeRetainedValue()
//        let orientation = photo.metadata[kCGImagePropertyOrientation as String] as! NSNumber
//        let uiOrientation = UIImage.Orientation(rawValue: orientation.intValue)!
//        let image = UIImage(cgImage: cgImage, scale: 1, orientation: uiOrientation)
    }
    
    @available(iOS 10.0, *)
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoBuffer, previewPhotoSampleBuffer: nil)
            camDelegate?.receiveData(data: photoData!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}



