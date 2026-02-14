<p align="center">
  <img src="https://roboui.dev/icons/icon-256.png" width="128" height="128" alt="RoboUI">
</p>

<h1 align="center">RoboUI</h1>

<p align="center">
  <strong>The native mobile SDK for robotics.</strong><br>
  Control any ROS2 robot from your phone.
</p>

<p align="center">
  <a href="https://roboui.dev">Website</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="CONTRIBUTING.md">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20Android-lightgrey?style=flat-square" alt="Platforms">
  <img src="https://img.shields.io/badge/ROS2-Humble-blue?style=flat-square" alt="ROS2">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/status-coming%20soon-yellow?style=flat-square" alt="Status">
</p>

---

## Why RoboUI?

Every robotics team builds their own control interface from scratch. Web dashboards that can't do haptics. Terminal tools that operators hate. Months of engineering time, reinventing the wheel.

**RoboUI gives you native mobile components for robotics — out of the box.**

> *"Foxglove is how you debug robots. RoboUI is how you operate them."*

## Features

| Feature | Web Dashboards | RoboUI |
|---------|---------------|--------|
| **Native Mobile SDK** | ❌ Browser only | ✅ iOS + Android |
| **Haptic Feedback** | ❌ Not possible | ✅ Feel collisions |
| **AR Overlay** | ❌ Not possible | ✅ Navigation paths |
| **Video Latency** | ~200-500ms | <100ms (WebRTC) |
| **Offline Mode** | ⚠️ Limited | ✅ Full offline |
| **On-Device AI** | ❌ Server-only | ✅ Edge inference |

### Components (planned)

- 📹 **CameraStream** — WebRTC low-latency video from robot cameras
- 🎮 **Joystick** — Virtual joystick with haptic feedback on collision
- 📊 **TelemetryPanel** — Battery, speed, IMU, custom sensors
- 🗺️ **FleetMap** — Real-time positions of multiple robots
- 🥽 **AROverlay** — Navigation paths and obstacles over camera feed
- 🛑 **EmergencyStop** — One-tap safety stop with confirmation haptic

## Quick Start

> ⚠️ **Coming soon.** The SDK is under active development. [Join the waitlist](https://roboui.dev) to get early access.

```swift
import RoboUI

struct ControlView: View {
    @StateObject var robot = RobotConnection("ws://turtlebot.local:9090")

    var body: some View {
        VStack {
            CameraStream(robot.topic("/camera/image"))
            TelemetryPanel(robot.telemetry)
            Joystick(robot.publisher("/cmd_vel"))
                .hapticFeedback(.collision)
        }
    }
}
```

```kotlin
// Android (Kotlin) — coming in Phase 2
val robot = RobotConnection("ws://turtlebot.local:9090")
RoboUIView(robot) {
    CameraStream(topic = "/camera/image")
    TelemetryPanel(robot.telemetry)
    Joystick(publisher = "/cmd_vel")
}
```

## Architecture

```
┌─────────────────────────────────────┐
│         Your Mobile App             │
│  ┌───────────────────────────────┐  │
│  │          RoboUI SDK           │  │
│  │  ┌─────────┐ ┌─────────────┐ │  │
│  │  │ UI Comp │ │  Telemetry  │ │  │
│  │  │ ponents │ │   Engine    │ │  │
│  │  └────┬────┘ └──────┬──────┘ │  │
│  │  ┌────┴──────────────┴──────┐ │  │
│  │  │    Transport Layer       │ │  │
│  │  │  WebSocket │ MQTT │ DDS  │ │  │
│  │  └────────────┬─────────────┘ │  │
│  └───────────────┼───────────────┘  │
└──────────────────┼──────────────────┘
                   │
          ┌────────┴────────┐
          │   rosbridge /   │
          │   MQTT broker   │
          └────────┬────────┘
                   │
┌──────────────────┼──────────────────┐
│           ROS2 Robot                │
│  Topics • Services • Actions       │
└─────────────────────────────────────┘
```

### Transport Options

| Transport | Use Case | Latency |
|-----------|----------|---------|
| **rosbridge (WebSocket)** | Universal ROS2 compatibility | ~50-100ms |
| **MQTT** | IoT / fleet telemetry | ~20-50ms |
| **Native DDS** | Direct ROS2 (no bridge) | ~5-20ms |
| **WebRTC** | Video streaming | <100ms E2E |

## Roadmap

- [x] Research & validation
- [ ] 🔨 Core SDK — connection manager, topic pub/sub
- [ ] 📹 Video streaming (WebRTC)
- [ ] 🎮 Virtual joystick with haptics
- [ ] 📊 Telemetry components
- [ ] 🗺️ Fleet map
- [ ] 🤖 Demo app (TurtleBot3)
- [ ] 📱 Android support (KMP)
- [ ] 🥽 AR overlay
- [ ] ☁️ Cloud relay for NAT traversal

## Use Cases

- **🏭 Warehouse** — Operators managing AMR fleets from tablets
- **🚜 Agriculture** — Monitoring autonomous tractors offline
- **🔍 Inspection** — Drone mission planning from any tablet
- **🦾 Teleoperation** — Remote manipulation with haptic feedback
- **🏠 Home Robotics** — Patrol robots integrated with smart home

## Contributing

We're building this in the open. Contributions, feedback, and ideas are welcome!

- 🐛 [Open an issue](https://github.com/RoboUI/roboui/issues)
- 💬 [Join the discussion](https://github.com/RoboUI/roboui/discussions)
- 📧 [hello@roboui.dev](mailto:hello@roboui.dev)

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup.

## License

MIT — see [LICENSE](LICENSE) for details.

---

<p align="center">
  <a href="https://roboui.dev">
    <img src="https://img.shields.io/badge/Join%20the%20Waitlist-roboui.dev-14b8a6?style=for-the-badge" alt="Join Waitlist">
  </a>
</p>
