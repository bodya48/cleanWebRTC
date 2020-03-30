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
}


class VideoCallViewController: UIViewController, ARDAppClientDelegate, RTCAudioSessionDelegate {
    
    weak var delegate: VideoCallViewControllerDelegate?
    var client: ARDAppClient?
    var roomId: String?
    
    @IBOutlet weak var hangUpButton: UIBarButtonItem!
    @IBOutlet weak var microphoneButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var switchCameraButton: UIBarButtonItem!
    
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.roomId!)
        
        let settingsModel = ARDSettingsModel()
        
        self.client = ARDAppClient.init(delegate: self)
        self.client?.connectToRoom(withId: self.roomId!, settings: settingsModel, isLoopback: false)
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
            
            default:
                print("ARDAppClientState. default case")
        }
    }
    
    
    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        
    }
    
    
    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        
    }
    
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        print(error.localizedDescription)
    }

    
    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
    }

    
    
    
    // MARK: - Actions
    @IBAction func hangUpButtonPressed(_ sender: Any) {
        delegate?.callDidFinish(self)
    }
    
    @IBAction func microphoneButtonPressed(_ sender: Any) {
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
    }
    
    @IBAction func switchCameraButtonPressed(_ sender: Any) {
    }

    
}
