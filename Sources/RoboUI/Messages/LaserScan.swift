import Foundation

/// ROS2 sensor_msgs/msg/LaserScan message.
public struct LaserScan: Sendable {
    public let angleMin: Float       // start angle (rad)
    public let angleMax: Float       // end angle (rad)
    public let angleIncrement: Float // angular step (rad)
    public let rangeMin: Float       // minimum range (m)
    public let rangeMax: Float       // maximum range (m)
    public let ranges: [Float]       // range data (m), inf = no return
    
    public init(
        angleMin: Float = 0,
        angleMax: Float = .pi * 2,
        angleIncrement: Float = 0,
        rangeMin: Float = 0,
        rangeMax: Float = 12,
        ranges: [Float] = []
    ) {
        self.angleMin = angleMin
        self.angleMax = angleMax
        self.angleIncrement = angleIncrement
        self.rangeMin = rangeMin
        self.rangeMax = rangeMax
        self.ranges = ranges
    }
    
    /// Parse from rosbridge JSON message.
    public static func from(dict: [String: Any]) -> LaserScan? {
        guard let ranges = dict["ranges"] as? [Any] else { return nil }
        
        return LaserScan(
            angleMin: floatValue(dict["angle_min"]),
            angleMax: floatValue(dict["angle_max"]),
            angleIncrement: floatValue(dict["angle_increment"]),
            rangeMin: floatValue(dict["range_min"]),
            rangeMax: floatValue(dict["range_max"]),
            ranges: ranges.compactMap { val -> Float? in
                if let d = val as? Double {
                    return d.isFinite ? Float(d) : nil
                }
                if let n = val as? NSNumber {
                    let d = n.doubleValue
                    return d.isFinite ? Float(d) : nil
                }
                return nil
            }
        )
    }
    
    /// Convert ranges to 2D points (x, y) in robot frame.
    public var points: [(x: Float, y: Float)] {
        var result: [(x: Float, y: Float)] = []
        result.reserveCapacity(ranges.count)
        
        for (i, range) in ranges.enumerated() {
            guard range >= rangeMin && range <= rangeMax else { continue }
            let angle = angleMin + Float(i) * angleIncrement
            result.append((
                x: range * cos(angle),
                y: range * sin(angle)
            ))
        }
        return result
    }
    
    private static func floatValue(_ value: Any?) -> Float {
        if let d = value as? Double { return Float(d) }
        if let n = value as? NSNumber { return n.floatValue }
        return 0
    }
}
