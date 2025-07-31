//
//  CameraManager+MotionManager.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import CoreMotion
import AVKit

@MainActor class CameraManagerMotionManager {
    private(set) var parent: CameraManager?
    private(set) var manager: CMMotionManager = .init()
}

// MARK: Setup
extension CameraManagerMotionManager {
    func setup(parent: CameraManager) {
        self.parent = parent
        manager.accelerometerUpdateInterval = 0.05
        manager.startAccelerometerUpdates(to: .current ?? .init(), withHandler: handleAccelerometerUpdates)
    }
}
private extension CameraManagerMotionManager {
    func handleAccelerometerUpdates(_ data: CMAccelerometerData?, _ error: Error?) {
        guard let data, error == nil else { return }

        let newDeviceOrientation = getDeviceOrientation(data.acceleration)
        updateDeviceOrientation(newDeviceOrientation)
        updateUserBlockedScreenRotation()
        updateFrameOrientation()
        redrawGrid()
    }
}
private extension CameraManagerMotionManager {
    func getDeviceOrientation(_ acceleration: CMAcceleration) -> AVCaptureVideoOrientation { switch acceleration {
        case let acceleration where acceleration.x >= 0.75: .landscapeLeft
        case let acceleration where acceleration.x <= -0.75: .landscapeRight
        case let acceleration where acceleration.y <= -0.75: .portrait
        case let acceleration where acceleration.y >= 0.75: .portraitUpsideDown
        default: parent?.attributes.deviceOrientation ?? .portrait
    }}
    func updateDeviceOrientation(_ newDeviceOrientation: AVCaptureVideoOrientation) {
        guard let parent else { return }
        
        if newDeviceOrientation != parent.attributes.deviceOrientation {
            parent.attributes.deviceOrientation = newDeviceOrientation
        }
    }
    func updateUserBlockedScreenRotation() {
        guard let parent else { return }
        let newUserBlockedScreenRotation = getNewUserBlockedScreenRotation()
        if newUserBlockedScreenRotation != parent.attributes.userBlockedScreenRotation { parent.attributes.userBlockedScreenRotation = newUserBlockedScreenRotation }
    }
    func updateFrameOrientation() {
        guard let parent else { return }
        
        if UIDevice.current.orientation != .portraitUpsideDown {
            let newFrameOrientation = getNewFrameOrientation(parent.attributes.orientationLocked ? .portrait : UIDevice.current.orientation)
            updateFrameOrientation(newFrameOrientation)
        }
    }
    func redrawGrid() {
        guard let parent else { return }

        if !parent.attributes.orientationLocked {
            parent.cameraGridView.draw(.zero)
        }
    }
}
private extension CameraManagerMotionManager {
    func getNewUserBlockedScreenRotation() -> Bool { switch parent?.attributes.deviceOrientation.rawValue == UIDevice.current.orientation.rawValue {
        case true: false
        case false: !(parent?.attributes.orientationLocked ?? false)
    }}
    func getNewFrameOrientation(_ orientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        switch parent?.attributes.cameraPosition ?? .front {
        case .back: getNewFrameOrientationForBackCamera(orientation)
        case .front: getNewFrameOrientationForFrontCamera(orientation)
        }
    }
    func updateFrameOrientation(_ newFrameOrientation: CGImagePropertyOrientation) {
        guard let parent = parent else { return }

        if newFrameOrientation != parent.attributes.frameOrientation {
            let shouldAnimate = shouldAnimateFrameOrientationChange(newFrameOrientation)
            updateFrameOrientation(withAnimation: shouldAnimate, newFrameOrientation: newFrameOrientation)
        }
    }
}
private extension CameraManagerMotionManager {
    func getNewFrameOrientationForBackCamera(_ orientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        let mirror = parent?.attributes.mirrorOutput ?? false
        
        return switch orientation {
        case .portrait: mirror ? .leftMirrored : .right
        case .landscapeLeft: mirror ? .upMirrored : .up
        case .landscapeRight: mirror ? .downMirrored : .down
        default: mirror ? .leftMirrored : .right
        }
    }
    func getNewFrameOrientationForFrontCamera(_ orientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        let mirror = parent?.attributes.mirrorOutput ?? false
        
        return switch orientation {
        case .portrait: mirror ? .right : .leftMirrored
        case .landscapeLeft: mirror ? .down : .downMirrored
        case .landscapeRight: mirror ? .up : .upMirrored
        default: mirror ? .right : .leftMirrored
        }
    }
    func shouldAnimateFrameOrientationChange(_ newFrameOrientation: CGImagePropertyOrientation) -> Bool {
        let backCameraOrientations: [CGImagePropertyOrientation] = [.left, .right, .up, .down],
            frontCameraOrientations: [CGImagePropertyOrientation] = [.leftMirrored, .rightMirrored, .upMirrored, .downMirrored],
            frameOrientation = parent?.attributes.frameOrientation ?? .up

        return (backCameraOrientations.contains(newFrameOrientation) && backCameraOrientations.contains(frameOrientation)) ||
        (frontCameraOrientations.contains(frameOrientation) && frontCameraOrientations.contains(newFrameOrientation))
    }
    func updateFrameOrientation(withAnimation shouldAnimate: Bool, newFrameOrientation: CGImagePropertyOrientation) {
        guard let parent = parent else { return }
        Task {
            await parent.cameraMetalView.beginCameraOrientationAnimation(if: shouldAnimate)
            parent.attributes.frameOrientation = newFrameOrientation
            parent.cameraMetalView.finishCameraOrientationAnimation(if: shouldAnimate)
        }
    }
}

// MARK: Reset
extension CameraManagerMotionManager {
    func reset() {
        manager.stopAccelerometerUpdates()
    }
}
