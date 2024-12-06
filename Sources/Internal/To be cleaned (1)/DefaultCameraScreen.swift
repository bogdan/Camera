//
//  DefaultCameraScreen.swift of MijickCameraView
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import SwiftUI

public struct DefaultCameraScreen: MCameraScreen {
    @ObservedObject public var cameraManager: CameraManager
    public let namespace: Namespace.ID
    public let closeControllerAction: () -> ()
    var config: Config = .init()


    public var body: some View {
        VStack(spacing: 0) {
            createTopView()
            createContentView()
            createBottomView()
        }
        .ignoresSafeArea(.all, edges: .horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.mijickBackgroundPrimary).ignoresSafeArea())
        .statusBarHidden()
        .animation(.mijickSpring, value: isRecording)
        .animation(.mijickSpring, value: cameraOutputType)
        .animation(.mijickSpring, value: hasLight)
        .animation(.mijickSpring, value: iconAngle)
    }
}
private extension DefaultCameraScreen {
    func createTopView() -> some View {
        DefaultCameraScreen.TopBar(parent: self)
            .padding(.top, 4)
            .padding(.bottom, 12)
            .padding(.horizontal, 20)
    }
    func createContentView() -> some View {
        ZStack {
            createCameraView()
            createOutputTypeButtons()
        }
    }
    func createBottomView() -> some View {
        DefaultCameraScreen.BottomBar(parent: self)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 32)
    }
}
private extension DefaultCameraScreen {
    func createOutputTypeButtons() -> some View {
        CameraOutputSwitch(parent: self)
            .transition(.asymmetric(insertion: .opacity.animation(.mijickSpring.delay(1)), removal: .scale.combined(with: .opacity)))
            .isActive(!isRecording)
            .isActive(config.outputTypePickerVisible)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 8)
    }
}
private extension DefaultCameraScreen {
    func createCloseButton() -> some View {
        CloseButton(action: closeControllerAction)
            .frame(maxWidth: .infinity, alignment: .leading)
            .isActive(!isRecording)
    }
    func createTopCentreView() -> some View {
        Text(recordingTime.toString())
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .foregroundColor(.init(.mijickTextPrimary))
            .isActive(isRecording)
    }
}
extension DefaultCameraScreen {
    var iconAngle: Angle { switch isOrientationLocked {
        case true: deviceOrientation.getAngle()
        case false: .zero
    }}
}

// MARK: - Configurables
extension DefaultCameraScreen { struct Config {
    var outputTypePickerVisible: Bool = true
    var lightButtonVisible: Bool = true
    var captureButtonVisible: Bool = true
    var changeCameraButtonVisible: Bool = true
    var gridButtonVisible: Bool = true
    var flipButtonVisible: Bool = true
    var flashButtonVisible: Bool = true
}}
