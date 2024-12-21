//
//  CameraManager+PhotoOutput.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import AVKit
import AVFoundation

@MainActor class CameraManagerPhotoOutput: NSObject {
    private(set) var parent: CameraManager!
    private(set) var output: AVCapturePhotoOutput = .init()
}

// MARK: Setup
extension CameraManagerPhotoOutput {
    func setup(parent: CameraManager) throws(MCameraError) {
        self.parent = parent
        try self.parent.captureSession.add(output: output)
    }
}


// MARK: - CAPTURE PHOTO



// MARK: Capture
extension CameraManagerPhotoOutput {
    func capture() {
        let settings = getPhotoOutputSettings()

        configureOutput()
        output.capturePhoto(with: settings, delegate: self)
        parent.cameraMetalView.performImageCaptureAnimation()
    }
}
private extension CameraManagerPhotoOutput {
    func getPhotoOutputSettings() -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = parent.attributes.flashMode.toDeviceFlashMode()
        return settings
    }
    func configureOutput() {
        guard let connection = output.connection(with: .video), connection.isVideoMirroringSupported else { return }

        connection.isVideoMirrored = parent.attributes.mirrorOutput ? parent.attributes.cameraPosition != .front : parent.attributes.cameraPosition == .front
        connection.videoOrientation = parent.attributes.deviceOrientation
    }
}

class MetadataCustomizer: NSObject, AVCapturePhotoFileDataRepresentationCustomizer {
    func replacementMetadata(for photo: AVCapturePhoto) -> [String : Any]? {
        return photo.metadata
    }
}

extension CameraManagerPhotoOutput: @preconcurrency AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        
        guard let imageData = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: imageData)
        else { return }

        let metadata = photo.metadata

        let capturedCIImage = prepareCIImage(ciImage, parent.attributes.cameraFilters)
        guard let capturedCGImage = prepareCGImage(capturedCIImage) else { return }
        
        let capturedUIImage = prepareUIImage(capturedCGImage)
        
        guard let finalImageData = reembedMetadata(to: capturedUIImage, with: metadata) else { return }
        
        let capturedMedia = MCameraMedia(data: UIImage(data: finalImageData))
        print(ImgUtils.extractMetadata(from: imageData))

        parent.setCapturedMedia(capturedMedia)
    }
}
private extension CameraManagerPhotoOutput {
    func prepareCIImage(_ ciImage: CIImage, _ filters: [CIFilter]) -> CIImage {
        ciImage.applyingFilters(filters)
    }
    func prepareCGImage(_ ciImage: CIImage) -> CGImage? {
        CIContext().createCGImage(ciImage, from: ciImage.extent)
    }
    func prepareUIImage(_ cgImage: CGImage?) -> UIImage? {
        guard let cgImage else { return nil }

        let frameOrientation = getFixedFrameOrientation()
        let orientation = UIImage.Orientation(frameOrientation)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }

    func reembedMetadata(to image: UIImage?, with metadata: [String: Any]) -> Data? {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 1.0)
        else { return nil }
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let uti = CGImageSourceGetType(source),
              let destinationData = NSMutableData() as CFMutableData?,
              let destination = CGImageDestinationCreateWithData(destinationData, uti, 1, nil)
        else { return nil }

        CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return destinationData as Data
    }
}


struct ImgUtils {
    static func extractMetadata(from image: Data) -> [String: Any] {
        guard let source = CGImageSourceCreateWithData(
            image as CFData, nil
        ) else {
            print("Failed to create image source.")
            return [:]
        }
        
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(
            source, 0, nil
        ) as? [String: Any] else {
            print("Failed to copy metadata.")
            return [:]
        }
        
        return metadata
        
    }
}

private extension CameraManagerPhotoOutput {
    func getFixedFrameOrientation() -> CGImagePropertyOrientation {
        guard UIDevice.current.orientation != parent.attributes.deviceOrientation.toDeviceOrientation() else { return parent.attributes.frameOrientation }

        return switch (parent.attributes.deviceOrientation, parent.attributes.cameraPosition) {
            case (.portrait, .front): .left
            case (.portrait, .back): .right
            case (.landscapeLeft, .back): .down
            case (.landscapeRight, .back): .up
            case (.landscapeLeft, .front) where parent.attributes.mirrorOutput: .up
            case (.landscapeLeft, .front): .upMirrored
            case (.landscapeRight, .front) where parent.attributes.mirrorOutput: .down
            case (.landscapeRight, .front): .downMirrored
            default: .right
        }
    }
}
