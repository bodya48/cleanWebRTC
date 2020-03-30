//
//  VideoCallViewController.swift
//  cleanWebRTC
//
//  Created by Bogdan Laukhin on 3/29/20.
//  Copyright © 2020 Bogdan Laukhin. All rights reserved.
//

import UIKit
import WebRTC


protocol VideoCallViewControllerDelegate: class {
    func callDidFinish(_ viewController: VideoCallViewController)
    func callDidFinish(_ viewController: VideoCallViewController, error: Error)
}


class VideoCallViewController: UIViewController, ARDAppClientDelegate, RTCAudioSessionDelegate, RTCVideoViewDelegate {
    
    let kLocalVideoViewSize     = 120 as CGFloat
    let kLocalVideoViewPadding  = 15 as CGFloat
    
    var micMuted        = false
    var videoStopped    = false
    
    weak var delegate: VideoCallViewControllerDelegate?
    
    var client: ARDAppClient?
    var roomId: String?
    
    var remoteVideoSize = CGSize.zero
    var remoteVideoTrack:   RTCVideoTrack?
    var remoteVideoView:    RTCEAGLVideoView?
    
    var localVideoView:     RTCCameraPreviewView?
    var captureController:  ARDCaptureController?
    
    @IBOutlet weak var hangUpButton: UIBarButtonItem!
    @IBOutlet weak var microphoneButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initRemoteView()
        self.initLocalView()
        self.updateToolBar()
        self.connect()
    }
    
    
    
    // MARK: - Actions
    @IBAction func hangUpButtonPressed(_ sender: Any) {
        self.closeCallViewController()
    }
    
    
    @IBAction func microphoneButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        if self.videoStopped {
            self.videoStopped = false
            self.captureController?.startCapture()
            self.cameraButton.tintColor = UIColor.systemBlue
        } else {
            self.videoStopped = true
            self.captureController?.stopCapture()
            self.cameraButton.tintColor = UIColor.darkGray
        }
    }
    
    
    @IBAction func switchCameraButtonPressed(_ sender: Any) {
        self.captureController?.switchCamera()
    }
    
    
    
    // MARK: - Dial, Hang Up
    func connect() {
        let settingsModel = ARDSettingsModel()
        self.client = ARDAppClient.init(delegate: self)
        self.client?.connectToRoom(withId: self.roomId!, settings: settingsModel, isLoopback: false)
    }
    
    
    
    func hangUp() {
        self.remoteVideoTrack = nil
        
        self.localVideoView?.captureSession = nil
        self.captureController?.stopCapture()
        self.captureController = nil
        
        self.client?.disconnect()
        self.closeCallViewController()
    }
    
    
    func closeCallViewController() {
        delegate?.callDidFinish(self)
    }
    
    
    
    // MARK: - ARDAppClientDelegate
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch state {
            case ARDAppClientState.connecting:
                print("ARDAppClientState.connecting")
            case ARDAppClientState.connected:
                print("ARDAppClientState.connected")
            case ARDAppClientState.disconnected:
                print("ARDAppClientState.disconnected")
                //self.hangUp()
            default:
                print("ARDAppClientState. unexpected case")
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        switch state {
            case RTCIceConnectionState.new:
                print("RTCIceConnectionState.new")
            case RTCIceConnectionState.checking:
                print("RTCIceConnectionState.checking")
            case RTCIceConnectionState.connected:
                print("RTCIceConnectionState.connected")
            case RTCIceConnectionState.completed:
                print("RTCIceConnectionState.completed")
            case RTCIceConnectionState.failed:
                print("RTCIceConnectionState.failed")
            case RTCIceConnectionState.disconnected:
                print("RTCIceConnectionState.disconnected")
            case RTCIceConnectionState.closed:
                print("RTCIceConnectionState.closed")
            case RTCIceConnectionState.count:
                print("RTCIceConnectionState.count")
            default:
                print("RTCIceConnectionState. unexpected case")
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        DispatchQueue.main.async {
            self.localVideoView!.captureSession = localCapturer.captureSession
            let settingsModel       = ARDSettingsModel()
            self.captureController  = ARDCaptureController(capturer: localCapturer, settings: settingsModel)
            self.captureController!.startCapture()
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        DispatchQueue.main.async {
            if self.remoteVideoTrack != nil { return }
            
            self.remoteVideoTrack = remoteVideoTrack
            self.remoteVideoTrack!.add(self.remoteVideoView!) // add renderer
            self.view.setNeedsLayout()
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        DispatchQueue.main.async {
            print(error.localizedDescription)
            self.showAlert(message: error.localizedDescription)
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
    }

    
    
    // MARK: - RTCVideoViewDelegate, LayoutSubviews
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        DispatchQueue.main.async {
            print("didChangeVideoSize", size)
            if videoView as! UIView == self.remoteVideoView! as UIView {
                self.remoteVideoSize = size
            }
            self.view.setNeedsLayout()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        self.layoutRemoteVideo(bounds)
        self.layoutLocalVideo(bounds)
    }

    
    func layoutRemoteVideo(_ bounds: CGRect) {
        print("layoutRemoteVideo")
        print(self.remoteVideoSize)
        if self.remoteVideoSize.width > 0 && self.remoteVideoSize.height > 0 {

            var remoteVideoFrame = AVMakeRect(aspectRatio: self.remoteVideoSize, insideRect: bounds)
            var scale = 1.0 as CGFloat
            
            if remoteVideoFrame.size.width > remoteVideoFrame.size.height {
                scale = bounds.size.height / remoteVideoFrame.size.height
            } else {
                scale = bounds.size.width / remoteVideoFrame.size.width
            }
            
            remoteVideoFrame.size.height *= scale
            remoteVideoFrame.size.width  *= scale
            
            self.remoteVideoView!.frame  = remoteVideoFrame
            self.remoteVideoView!.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        else {
            self.remoteVideoView!.frame  = bounds
        }
    }
    
    
    func layoutLocalVideo(_ bounds: CGRect) {
        print("layoutLocalVideo")
        // Place the view in the bottom right.
        var localVideoFrame         = CGRect(x: 0, y: 0, width: kLocalVideoViewSize, height: kLocalVideoViewSize)
        localVideoFrame.origin.x    = bounds.maxX - localVideoFrame.size.width - kLocalVideoViewPadding
        localVideoFrame.origin.y    = bounds.maxY - localVideoFrame.size.height - self.toolBar.frame.size.height - kLocalVideoViewPadding
        self.localVideoView!.frame  = localVideoFrame
    }
    
    
    
    // MARK: - Initi Views
    func initRemoteView() {
        // using metal
        // self.remoteVideoView = RTCMTLVideoView(frame: CGRect.zero)
        //self.remoteVideoView = RTCEAGLVideoView(frame: self.view.frame)
        
        self.remoteVideoView            = RTCEAGLVideoView(frame: self.view.frame)
        self.remoteVideoView!.delegate  = self
        self.view.addSubview(self.remoteVideoView!)
        self.view.bringSubviewToFront(self.remoteVideoView!)
    }
    
    
    func initLocalView() {
        let localViewFrame  = CGRect(x: 0, y: 0, width: kLocalVideoViewSize, height: kLocalVideoViewSize)
        self.localVideoView = RTCCameraPreviewView(frame: localViewFrame)
        self.view.addSubview(self.localVideoView!)
        self.view.bringSubviewToFront(self.localVideoView!)
    }
    
    
    func updateToolBar() {
        self.view.bringSubviewToFront(self.toolBar)
    }
    
    
    
    // MARK: - Alert Message
    func showAlert(message: String) {
        let alert   = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        let action  = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
            self.hangUp()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
