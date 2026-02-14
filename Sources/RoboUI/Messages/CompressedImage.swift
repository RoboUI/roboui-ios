// RoboUI — CompressedImage
// sensor_msgs/msg/CompressedImage

import Foundation

/// ROS2 `sensor_msgs/msg/CompressedImage` message.
///
/// Received via rosbridge as JSON with base64-encoded `data` field.
public struct CompressedImage: Sendable {
    /// Image format: "jpeg", "png", etc.
    public let format: String
    
    /// Raw image data (decoded from base64).
    public let data: Data
    
    /// Frame ID from the header.
    public let frameId: String
    
    /// Timestamp (seconds since epoch).
    public let timestamp: Double
    
    /// Parse from rosbridge JSON dictionary.
    ///
    /// Expected structure:
    /// ```json
    /// {
    ///   "header": { "stamp": { "sec": 123, "nanosec": 456 }, "frame_id": "camera_link" },
    ///   "format": "jpeg",
    ///   "data": "<base64-encoded>"
    /// }
    /// ```
    public static func from(dict: [String: Any]) -> CompressedImage? {
        guard let format = dict["format"] as? String,
              let base64String = dict["data"] as? String else {
            return nil
        }
        
        // rosbridge sends image data as base64
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        
        // Parse header
        var frameId = ""
        var timestamp: Double = 0
        if let header = dict["header"] as? [String: Any] {
            frameId = (header["frame_id"] as? String) ?? ""
            if let stamp = header["stamp"] as? [String: Any] {
                let sec = (stamp["sec"] as? Double) ?? Double((stamp["sec"] as? Int) ?? 0)
                let nanosec = (stamp["nanosec"] as? Double) ?? Double((stamp["nanosec"] as? Int) ?? 0)
                timestamp = sec + nanosec / 1_000_000_000
            }
        }
        
        return CompressedImage(
            format: format,
            data: imageData,
            frameId: frameId,
            timestamp: timestamp
        )
    }
}
