<p align="center">
  <img src="https://roboui.dev/icons/icon-256.png" width="128" height="128" alt="RoboUI">
</p>

<h1 align="center">RoboUI</h1>

<p align="center">
  <strong>The open-source SDK for building robot control apps.</strong><br>
  Native iOS components for ROS2 — drop in a joystick, LiDAR view, or telemetry panel and ship.
</p>

<p align="center">
  <a href="https://roboui.dev">Website</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#components">Components</a> •
  <a href="#demo">Demo</a> •
  <a href="https://github.com/RoboUI/roboui-android">Android SDK</a> •
  <a href="CONTRIBUTING.md">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/platforms-iOS%2016%2B%20%7C%20macOS%2013%2B-lightgrey?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/ROS2-Humble-blue?style=flat-square" alt="ROS2">
  <img src="https://img.shields.io/badge/dependencies-zero-brightgreen?style=flat-square" alt="Dependencies">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
</p>

---

<!-- TODO: Replace with actual demo GIF -->
<!-- <p align="center">
  <img src="docs/demo.gif" width="300" alt="RoboUI Demo — iPhone controlling TurtleBot3 with LiDAR">
</p> -->

## Why RoboUI?

Every robotics team builds mobile control UI from scratch. RoboUI is **Mapbox for robotics** — you don't build maps from scratch, so why build robot UI from scratch?

```
┌─────────────────────────────────────────────┐
│     Your App (custom branding & logic)       │
├─────────────────────────────────────────────┤
│     RoboUI SDK (MIT, free)                   │
│     Joystick · LiDAR · Video · Telemetry     │
├─────────────────────────────────────────────┤
│     rosbridge WebSocket                      │
├─────────────────────────────────────────────┤
│     Any ROS2 Robot                           │
└─────────────────────────────────────────────┘
```

**Not an app — a toolkit.** If you want a ready-to-use app, check out [RoboUI App](#roboui-app). If you want to build YOUR app, use the SDK.

## Quick Start

### 1. Add the dependency

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/RoboUI/roboui-ios.git", from: "0.1.0")
]
```

### 2. Connect to your robot

```swift
import RoboUI

// Connect to any ROS2 robot running rosbridge
let connection = RosbridgeConnection(url: URL(string: "ws://robot.local:9090")!)
connection.connect()
```

### 3. Drop in components

```swift
import SwiftUI
import RoboUI

struct RobotControlView: View {
    @StateObject var connection = RosbridgeConnection(
        url: URL(string: "ws://robot.local:9090")!
    )
    @StateObject var publisher = TwistPublisher()

    var body: some View {
        ZStack {
            // Real-time LiDAR visualization
            LaserScanView(scanData: latestScan)

            // Virtual joystick → publishes Twist to /cmd_vel
            JoystickView { vector in
                publisher.publish(
                    linear: vector.y * 0.5,
                    angular: -vector.x * 1.0,
                    connection: connection
                )
            }
        }
    }
}
```

**That's it.** Your app now controls a ROS2 robot with LiDAR visualization.

## Components

### Available Now

| Component | Description | Topics |
|-----------|-------------|--------|
| **`RosbridgeConnection`** | WebSocket client for rosbridge v2.0 protocol | Any |
| **`JoystickView`** | Virtual joystick with spring-back animation | → `/cmd_vel` |
| **`DualJoystickView`** | Move + rotate for mecanum/omnidirectional drive | → `/cmd_vel` |
| **`LaserScanView`** | LiDAR point cloud radial visualization | ← `/scan` |
| **`TwistPublisher`** | Differential drive command publisher | → `/cmd_vel` |
| **`MecanumPublisher`** | Omnidirectional drive (x, y, rotation) | → `/cmd_vel` |

### Message Types

| Type | ROS2 Equivalent |
|------|----------------|
| `Vector3` | `geometry_msgs/Vector3` |
| `Twist` | `geometry_msgs/Twist` |
| `LaserScan` | `sensor_msgs/LaserScan` |

### Coming Soon

- 📹 **CameraView** — compressed image / WebRTC video stream
- 📊 **TelemetryView** — battery, speed, IMU, custom sensors
- 🗺️ **MapView** — occupancy grid + robot position + navigation goals
- 🛑 **EmergencyStopButton** — safety stop with haptic confirmation
- 🔄 **Auto-reconnect** — exponential backoff with status indicator

## Demo

<!-- TODO: Add demo video/GIF here -->

The [iOS demo app](https://github.com/RoboUI/roboui-demo-ios) shows a full control interface:
- Connect to any rosbridge endpoint
- Drive with virtual joystick
- Real-time LiDAR overlay on mini-map
- Odometry tracking with position trail

### Run the demo yourself

```bash
# 1. Start a ROS2 environment with rosbridge
docker run -p 9090:9090 roboui/ros2-dev  # or your own ROS2 setup

# 2. Clone and open the demo
git clone https://github.com/RoboUI/roboui-demo-ios
cd roboui-demo-ios
xcodegen generate
open RoboUIDemo.xcodeproj

# 3. Run on simulator or device
# Select your target and press ⌘R
```

## Architecture

```
Phone/Tablet                          Robot
┌──────────────────┐     WebSocket    ┌──────────────────┐
│   Your App       │                  │   ROS2           │
│  ┌────────────┐  │   rosbridge     │  ┌────────────┐  │
│  │  RoboUI    │◄─┼──────────────►──┼──│  Topics    │  │
│  │  SDK       │  │   pub/sub       │  │  Services  │  │
│  └────────────┘  │                  │  │  Actions   │  │
└──────────────────┘                  │  └────────────┘  │
                                      └──────────────────┘
```

**Zero dependencies.** Uses only Foundation `URLSessionWebSocketTask` for transport. No Starscream, no Combine, no third-party frameworks.

### Supported Platforms

| Platform | Status | Min Version |
|----------|--------|-------------|
| iOS | ✅ Working | 16.0+ |
| macOS | ✅ Working | 13.0+ |
| Android | 🗓️ Phase 2 | — |

## RoboUI App

Don't want to build a custom app? The **RoboUI App** (coming soon) gives you ready-to-use robot control from your phone — built entirely on this SDK.

- Free tier: 1 robot, basic controls
- Pro: multi-robot, video recording, custom layouts

The app is the best demo of what the SDK can do. [Join the waitlist →](https://roboui.dev)

## Roadmap

- [x] **Transport** — rosbridge WebSocket client
- [x] **Joystick** — virtual joystick with spring-back
- [x] **Drive** — differential + mecanum publishers
- [x] **LiDAR** — LaserScan point cloud visualization
- [ ] **Camera** — compressed image + WebRTC video
- [ ] **Telemetry** — battery, speed, IMU panels
- [ ] **Map** — occupancy grid + Nav2 goals
- [ ] **E-Stop** — emergency stop with haptics
- [ ] **Auto-reconnect** — exponential backoff
- [ ] **Android SDK** — Kotlin implementation
- [ ] **Cloud Relay** — NAT traversal for remote robots
- [ ] **TaaS** — Teleoperation-as-a-Service platform

## Why Not Web?

| | Web Dashboard | RoboUI (Native) |
|--|--------------|-----------------|
| Haptic feedback | ❌ | ✅ Feel collisions |
| Touch latency | ~100-200ms | <16ms (60fps native) |
| Offline mode | ⚠️ Limited | ✅ Full offline |
| Camera/AR access | ❌ | ✅ ARKit/ARCore |
| App Store distribution | ❌ | ✅ Ship to operators |
| On-device ML | ❌ | ✅ CoreML/TFLite |

## Contributing

We're building this in the open. All contributions welcome!

- 🐛 [Open an issue](https://github.com/RoboUI/roboui-ios/issues)
- 💬 [Discussions](https://github.com/RoboUI/roboui-ios/discussions)
- 📧 [hello@roboui.dev](mailto:hello@roboui.dev)

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <a href="https://roboui.dev">
    <img src="https://img.shields.io/badge/Join%20the%20Waitlist-roboui.dev-14b8a6?style=for-the-badge" alt="Join Waitlist">
  </a>
</p>
