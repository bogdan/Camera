//
//  CameraManagerVideo.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import AVKit
import MijickTimer

@MainActor class CameraManagerVideo: NSObject {
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var recordingTime: MTime = .zero
    private(set) var parent: CameraManager!
    private(set) var videoOutput: AVCaptureMovieFileOutput = .init()
    private(set) var timer: MTimer = .createNewInstance()
    private(set) var firstRecordedFrame: UIImage?
}

// MARK: Setup
extension CameraManagerVideo {
    func setup(parent: CameraManager) throws {
        self.parent = parent
        try parent.captureSession.add(output: videoOutput)
    }
}

// MARK: Reset
extension CameraManagerVideo {
    func reset() {
        timer.reset()
    }
}


// MARK: - CAPTURE VIDEO



// MARK: Toggle
extension CameraManagerVideo {
    func toggleRecording() { switch videoOutput.isRecording {
        case true: stopRecording()
        case false: startRecording()
    }}
}

// MARK: Start Recording
private extension CameraManagerVideo {
    func startRecording() {
        guard let url = prepareUrlForVideoRecording() else { return }

        configureOutput()
        storeLastFrame()
        videoOutput.startRecording(to: url, recordingDelegate: self)
        isRecording = true
        startRecordingTimer()
    }
}
private extension CameraManagerVideo {
    func prepareUrlForVideoRecording() -> URL? {
        FileManager.prepareURLForVideoOutput()
    }
    func configureOutput() {
        guard let connection = videoOutput.connection(with: .video), connection.isVideoMirroringSupported else { return }

        connection.isVideoMirrored = parent.attributes.mirrorOutput ? parent.attributes.cameraPosition != .front : parent.attributes.cameraPosition == .front
        connection.videoOrientation = parent.attributes.deviceOrientation
    }
    func storeLastFrame() {
        guard let texture = parent.cameraMetalView.currentDrawable?.texture,
              let ciImage = CIImage(mtlTexture: texture, options: nil),
              let cgImage = parent.cameraMetalView.ciContext.createCGImage(ciImage, from: ciImage.extent)
        else { return }

        firstRecordedFrame = UIImage(cgImage: cgImage, scale: 1.0, orientation: parent.attributes.deviceOrientation.toImageOrientation())
    }
    func startRecordingTimer() {
        try? timer
            .publish(every: 1) { [self] in recordingTime = $0 }
            .start()
    }
}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}

// MARK: Stop Recording
private extension CameraManagerVideo {
    func stopRecording() {

    }
}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}

// MARK: Receive Data
extension CameraManagerVideo: @preconcurrency AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Swift.Error)?) { Task {
        parent.attributes.capturedMedia = try await .create(videoData: outputFileURL, filters: parent.attributes.cameraFilters)
    }}
}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}
private extension CameraManagerVideo {

}
