import Foundation
import Combine

/// Publishes Twist messages optimized for Mecanum wheel robots.
///
/// Unlike differential drive (linear.x + angular.z only),
/// Mecanum wheels support full omnidirectional movement:
/// - `linear.x` → forward/backward
/// - `linear.y` → strafe left/right
/// - `angular.z` → rotation
///
/// Usage:
/// ```swift
/// let mecanum = MecanumPublisher(connection: robot)
/// mecanum.drive(x: 0.3, y: -0.2, rotation: 0.5)
/// ```
@MainActor
public final class MecanumPublisher: ObservableObject {
    
    private let connection: RosbridgeConnection
    private let topic: String
    private var isAdvertised = false
    
    @Published public var lastVelocity: MecanumVelocity = .zero
    
    /// Maximum velocities for clamping (m/s and rad/s)
    public var maxLinear: Double = 0.5
    public var maxAngular: Double = 1.0
    
    public init(connection: RosbridgeConnection, topic: String = "/cmd_vel") {
        self.connection = connection
        self.topic = topic
    }
    
    /// Start advertising the topic.
    public func start() {
        guard !isAdvertised else { return }
        connection.advertise(topic: topic, type: "geometry_msgs/msg/Twist")
        isAdvertised = true
    }
    
    /// Stop advertising and send zero velocity.
    public func stop() {
        publish(.zero)
        guard isAdvertised else { return }
        connection.unadvertise(topic: topic)
        isAdvertised = false
    }
    
    /// Drive with omnidirectional velocities.
    /// - Parameters:
    ///   - x: Forward/backward (-1...1), scaled by maxLinear
    ///   - y: Strafe left/right (-1...1), scaled by maxLinear
    ///   - rotation: Rotation (-1...1), scaled by maxAngular
    public func drive(x: Double, y: Double, rotation: Double) {
        let velocity = MecanumVelocity(
            x: clamp(x, -1, 1) * maxLinear,
            y: clamp(y, -1, 1) * maxLinear,
            rotation: clamp(rotation, -1, 1) * maxAngular
        )
        publish(velocity)
    }
    
    /// Publish a raw MecanumVelocity.
    public func publish(_ velocity: MecanumVelocity) {
        if !isAdvertised { start() }
        lastVelocity = velocity
        
        let twist = Twist(
            linear: Vector3(x: velocity.x, y: velocity.y),
            angular: Vector3(z: velocity.rotation)
        )
        connection.publish(topic: topic, message: twist.dict)
    }
    
    /// Emergency stop — send zero velocity.
    public func emergencyStop() {
        publish(.zero)
    }
    
    private func clamp(_ value: Double, _ min: Double, _ max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}

/// Velocity state for mecanum drive.
public struct MecanumVelocity: Equatable, Sendable {
    public let x: Double        // forward/backward (m/s)
    public let y: Double        // strafe left/right (m/s)
    public let rotation: Double // rotation (rad/s)
    
    public static let zero = MecanumVelocity(x: 0, y: 0, rotation: 0)
    
    public init(x: Double = 0, y: Double = 0, rotation: Double = 0) {
        self.x = x
        self.y = y
        self.rotation = rotation
    }
    
    /// Speed magnitude (m/s)
    public var speed: Double {
        hypot(x, y)
    }
    
    /// Movement heading in radians (0 = forward, π/2 = left)
    public var heading: Double {
        atan2(y, x)
    }
}
