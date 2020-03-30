//
//  ViewController.swift
//  cleanWebRTC
//
//  Created by Bogdan Laukhin on 3/29/20.
//  Copyright © 2020 Bogdan Laukhin. All rights reserved.
//

import UIKit
import WebRTC


class EntryViewController: UIViewController, UITextFieldDelegate, RTCAudioSessionDelegate, VideoCallViewControllerDelegate {
    
    @IBOutlet weak var roomIdTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        self.view.isUserInteractionEnabled = true
        
        self.roomIdTextField?.becomeFirstResponder()
    }
    
    
    
    // MARK: - Actions
    @IBAction func joinCallButtonTapped(_ sender: Any) {
        self.hideKeyboard()
        
        if self.roomIdTextField?.text == "" {
            self.showAlert(message: "Missing room id")
            return
        }
        
        self.showRoomView()
    }
    
    
    // MARK: - Navigation
    func showRoomView() {
        let audioSession = RTCAudioSession.sharedInstance()
        audioSession.isAudioEnabled = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "videoCall") as! VideoCallViewController
        controller.modalPresentationStyle   = UIModalPresentationStyle.fullScreen
        controller.modalTransitionStyle     = UIModalTransitionStyle.coverVertical
        controller.delegate = self
        controller.roomId   = self.roomIdTextField!.text! as String
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
    func callDidFinish(_ viewController: VideoCallViewController) {
        if !viewController.isBeingDismissed {
            viewController.dismiss(animated: true, completion: nil)
        }
        
        let audioSession = RTCAudioSession.sharedInstance()
        audioSession.isAudioEnabled = false
    }
    
    
    
    // MARK: - Hide keyboard
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.hideKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
    
    func hideKeyboard() {
        self.roomIdTextField?.resignFirstResponder()
    }
    
    
    // MARK: - Alert Message
    func showAlert(message: String) {
        let alert   = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        let action  = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}

