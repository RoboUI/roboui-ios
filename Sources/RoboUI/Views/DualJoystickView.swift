import SwiftUI

/// A dual-joystick layout for omnidirectional robots.
///
/// Left joystick: X/Y movement (strafe + forward/back)
/// Right joystick: Rotation
///
/// Usage:
/// ```swift
/// DualJoystickView { x, y, rotation in
///     mecanum.drive(x: y, y: -x, rotation: rotation)
/// }
/// ```
public struct DualJoystickView: View {
    
    public typealias DriveHandler = (_ x: Double, _ y: Double, _ rotation: Double) -> Void
    
    private let size: CGFloat
    private let onDrive: DriveHandler
    private let onRelease: (() -> Void)?
    
    @State private var moveX: Double = 0
    @State private var moveY: Double = 0
    @State private var rotation: Double = 0
    
    public init(
        size: CGFloat = 150,
        onRelease: (() -> Void)? = nil,
        onDrive: @escaping DriveHandler
    ) {
        self.size = size
        self.onDrive = onDrive
        self.onRelease = onRelease
    }
    
    public var body: some View {
        HStack(spacing: 40) {
            // Left: Movement (X/Y)
            VStack(spacing: 4) {
                JoystickView(size: size, onRelease: {
                    moveX = 0
                    moveY = 0
                    onDrive(0, 0, rotation)
                    if rotation == 0 { onRelease?() }
                }, onChange: { x, y in
                    moveX = x
                    moveY = y
                    onDrive(moveX, moveY, rotation)
                })
                
                Text("Move")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            // Right: Rotation
            VStack(spacing: 4) {
                JoystickView(size: size, onRelease: {
                    rotation = 0
                    onDrive(moveX, moveY, 0)
                    if moveX == 0 && moveY == 0 { onRelease?() }
                }, onChange: { x, _ in
                    // Only use horizontal axis for rotation
                    rotation = x
                    onDrive(moveX, moveY, rotation)
                })
                
                Text("Rotate")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    DualJoystickView { x, y, rotation in
        print("x: \(x), y: \(y), rot: \(rotation)")
    }
    .padding()
}
