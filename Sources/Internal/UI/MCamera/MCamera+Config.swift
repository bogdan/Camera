//
//  MCamera+Config.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import SwiftUI

extension MCamera { @MainActor class Config {
    // MARK: Screens
    var cameraScreen: CameraScreenBuilder = { manager, id, dismiss in
        DefaultCameraScreen(cameraManager: manager, namespace: id, closeMCameraAction: dismiss)
    }
    var capturedMediaScreen: CapturedMediaScreenBuilder? = { media, namespace, retakeAction, acceptMediaAction in
        DefaultCapturedMediaScreen(
            capturedMedia: media,
            namespace: namespace,
            retakeAction: retakeAction,
            acceptMediaAction: acceptMediaAction
        )
    }
    var errorScreen: ErrorScreenBuilder = { error, action in
        DefaultCameraErrorScreen(error: error, closeMCameraAction: action)
    }

    // MARK: Actions
    var imageCapturedAction: (Data, MCamera.Controller) -> () = { _,_ in }
    var videoCapturedAction: (URL, MCamera.Controller) -> () = { _,_ in }
    var closeMCameraAction: () -> () = {}

    // MARK: Others
    var appDelegate: MApplicationDelegate.Type? = nil
    var isCameraConfigured: Bool = false
}}
