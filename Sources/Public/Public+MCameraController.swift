//
//  Public+MCameraController.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI
import AVKit

// MARK: - Initialiser
public extension MCameraController {
    //init() { }
}

// MARK: - Changing Default Views
public extension MCameraController {
    /// Replaces the default Camera Screen with a new one of your choice (pass the initialiser as an argument of this method).
    /// For more information, see the project documentation (https://github.com/Mijick/CameraView)
    func cameraScreen(_ builder: @escaping CameraViewBuilder) -> Self { setAndReturnSelf { $0.config.cameraView = builder } }

    /// Replaces the default Media Preview Screen with a new one of your choice (pass the initialiser as an argument of this method).
    /// For more information, see the project documentation (https://github.com/Mijick/CameraView)
    func mediaPreviewScreen(_ builder: PreviewViewBuilder?) -> Self { setAndReturnSelf { $0.config.mediaPreviewView = builder } }

    /// Replaces the default Error Screen with a new one of your choice (pass the initialiser as an argument of this method).
    /// For more information, see the project documentation (https://github.com/Mijick/CameraView)
    func errorScreen(_ builder: @escaping ErrorViewBuilder) -> Self { setAndReturnSelf { $0.config.cameraErrorView = builder } }
}

// MARK: - Actions
public extension MCameraController {
    /// Sets the action to be triggered when the photo is taken. Passes the captured content as an argument
    func onImageCaptured(_ action: @escaping (UIImage) -> ()) -> Self { setAndReturnSelf { $0.config.onImageCaptured = action } }

    /// Sets the action to be triggered when the video is taken. Passes the captured content as an argument
    func onVideoCaptured(_ action: @escaping (URL) -> ()) -> Self { setAndReturnSelf { $0.config.onVideoCaptured = action } }

    /// Sets the action triggered when a photo or video is taken
    func afterMediaCaptured(_ action: @escaping (PostCameraConfig) -> (PostCameraConfig)) -> Self { setAndReturnSelf { $0.config.afterMediaCaptured = action } }

    /// Determines what happens when the Camera Controller should be closed
    func onCloseController(_ action: @escaping () -> ()) -> Self { setAndReturnSelf { $0.config.onCloseController = action } }
}

// MARK: - Others
public extension MCameraController {
    /// Locks the camera interface in portrait orientation (even if device screen rotation is enabled).
    /// For more information, see the project documentation (https://github.com/Mijick/CameraView)
    func lockOrientation(_ appDelegate: MApplicationDelegate.Type) -> Self { setAndReturnSelf { $0.config.appDelegate = appDelegate; $0.cameraManager.attributes.orientationLocked = true } }
}



public extension MCameraController {
    func outputType(_ type: CameraOutputType) -> Self { setAndReturnSelf { $0.cameraManager.attributes.outputType = type } }
    func cameraPosition(_ position: CameraPosition) -> Self { setAndReturnSelf { $0.cameraManager.attributes.cameraPosition = position } }
    func cameraFilters(_ filters: [CIFilter]) -> Self { setAndReturnSelf { $0.cameraManager.attributes.cameraFilters = filters } }
    func resolution(_ resolution: AVCaptureSession.Preset) -> Self { setAndReturnSelf { $0.cameraManager.attributes.resolution = resolution } }
    func frameRate(_ frameRate: Int32) -> Self { setAndReturnSelf { $0.cameraManager.attributes.frameRate = frameRate } }
    func flashMode(_ mode: CameraFlashMode) -> Self { setAndReturnSelf { $0.cameraManager.attributes.flashMode = mode } }
    func gridVisibility(_ isVisible: Bool) -> Self { setAndReturnSelf { $0.cameraManager.attributes.isGridVisible = isVisible } }

    func focusImage(_ image: UIImage) -> Self {  setAndReturnSelf { $0.cameraManager.cameraMetalView.focusIndicatorConfig.image = image } }
    func focusImageColor(_ color: UIColor) -> Self {  setAndReturnSelf { $0.cameraManager.cameraMetalView.focusIndicatorConfig.tintColor = color } }
    func focusImageSize(_ size: CGFloat) -> Self {  setAndReturnSelf { $0.cameraManager.cameraMetalView.focusIndicatorConfig.size = size } }
}



public extension MCameraController {
    func start() -> some View { setAndReturnSelf { $0.config.isInitialised = true } }
}