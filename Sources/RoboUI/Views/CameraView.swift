// RoboUI — CameraView
// Displays a live video feed from a ROS2 compressed image topic.

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

/// A SwiftUI view that displays a live camera feed from a ROS2 compressed image topic.
///
/// Usage:
/// ```swift
/// CameraView(image: viewModel.latestImage)
/// ```
///
/// Or with overlay:
/// ```swift
/// CameraView(image: viewModel.latestImage) {
///     Text("REC")
///         .foregroundStyle(.red)
///         .padding(8)
/// }
/// ```
public struct CameraView<Overlay: View>: View {
    let image: CompressedImage?
    let contentMode: ContentMode
    let overlay: Overlay
    
    /// Create a camera view with an optional overlay.
    /// - Parameters:
    ///   - image: The latest `CompressedImage` from a subscription.
    ///   - contentMode: How the image fills the view. Default: `.fit`.
    ///   - overlay: Optional overlay content rendered on top of the image.
    public init(
        image: CompressedImage?,
        contentMode: ContentMode = .fit,
        @ViewBuilder overlay: () -> Overlay
    ) {
        self.image = image
        self.contentMode = contentMode
        self.overlay = overlay()
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.black
            
            if let image = image, let uiImage = Self.decodeImage(image.data) {
                #if canImport(UIKit)
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #elseif canImport(AppKit)
                Image(nsImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                #endif
            } else {
                // Placeholder when no image
                VStack(spacing: 12) {
                    Image(systemName: "video.slash")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No Video")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            overlay
        }
        .clipped()
    }
    
    /// Decode raw image data (JPEG/PNG) into a platform image.
    private static func decodeImage(_ data: Data) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #endif
    }
}

// MARK: - Convenience init without overlay

extension CameraView where Overlay == EmptyView {
    /// Create a camera view without overlay.
    /// - Parameters:
    ///   - image: The latest `CompressedImage` from a subscription.
    ///   - contentMode: How the image fills the view. Default: `.fit`.
    public init(
        image: CompressedImage?,
        contentMode: ContentMode = .fit
    ) {
        self.image = image
        self.contentMode = contentMode
        self.overlay = EmptyView()
    }
}

// MARK: - CameraOverlay (common HUD elements)

/// Pre-built camera HUD overlay with recording indicator and format info.
public struct CameraHUD: View {
    let image: CompressedImage?
    let showRecIndicator: Bool
    
    public init(image: CompressedImage?, showRecIndicator: Bool = true) {
        self.image = image
        self.showRecIndicator = showRecIndicator
    }
    
    @State private var recBlink = true
    
    public var body: some View {
        ZStack {
            // Top-left: format info
            VStack {
                HStack {
                    if let img = image {
                        Text("\(img.format.uppercased()) • \(img.frameId)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(6)
                            .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
                    }
                    Spacer()
                    
                    // Top-right: REC
                    if showRecIndicator && image != nil {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                                .opacity(recBlink ? 1 : 0.3)
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.red)
                        }
                        .padding(6)
                        .background(.black.opacity(0.3), in: RoundedRectangle(cornerRadius: 4))
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                                recBlink.toggle()
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(8)
        }
    }
}
