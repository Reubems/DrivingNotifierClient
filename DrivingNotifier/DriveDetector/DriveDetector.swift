//  Copyright © 2017 Jakob Jensen. All rights reserved.

import Foundation
import CoreMotion
import CoreLocation
import CocoaLumberjack

protocol DriveDetectorDelegate: NSObjectProtocol {
    func didUpdate(_ detection: DriveDetection)
}

class DriveDetector: NSObject {
    private var state = DriveDetectorState.idle {
        didSet {
            if oldValue != state {
                DDLogDebug("did change state from \(oldValue) to \(state)")
                retryCount = 0
            }
        }
    }
    private var retryCount = 0
    private var delegates: [DriveDetectorDelegate] = []

    private var detection: DriveDetection
    private var previousLocation: CLLocation?
    private var locationManager: CLLocationManager?
    private var taskIdentifier: UIBackgroundTaskIdentifier?

    private let motionManager = CMMotionActivityManager()
    private let motionQueue = OperationQueue()

    private let maxRetryCount = 3
    private let maxLocationAge: Double = 30
    private let maxLocationInaccuracy: Double = 65

    override init() {
        let location = CLLocationManager().location ?? CLLocation()
        detection = DriveDetection(
            detecting: false,
            date: location.timestamp,
            region: DriveDetectionRegion(center: location.coordinate),
            accuracy: location.horizontalAccuracy,
            state: .notDriving,
            permissionState: nil
        )
        super.init()
        motionQueue.maxConcurrentOperationCount = 1
    }

    func activate() {
        switch state {
        case .askForMotion:
            fallthrough // swiftlint:disable:this no_fallthrough_only
        case .askForLocation:
            fallthrough // swiftlint:disable:this no_fallthrough_only
        case .idle:
            state = .askForLocation
            detection = detection.with(state: .notDriving).with(detecting: false).with(permissionState: nil)
            locationManager?.delegate = nil
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = 20
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func deactivate() {
        guard state != .idle else { return }
        locationManager?.delegate = nil
        locationManager = nil
        state = .idle
        detection = detection.with(state: .notDriving).with(detecting: false).with(permissionState: nil)
        didUpdate(detection)
    }

    func add(observer: DriveDetectorDelegate) {
        observer.didUpdate(detection)
        delegates.append(observer)
    }

    func remove(observer: DriveDetectorDelegate) {
        delegates = delegates.filter { !observer.isEqual($0) }
    }

    func performUpdate() {
        reportStop()
    }

    private func calculateSpeed(between location: CLLocation, and previousLocation: CLLocation?) -> Double {
        var speed = -1.0
        if let previousLocation = previousLocation {
            let distance = previousLocation.distance(from: location)
            let duration = location.timestamp.timeIntervalSince(previousLocation.timestamp)
            if distance > 50 && duration > 2 {
                speed = distance * 3.6 / duration
            }
        }
        return speed
    }

    private func detect(manager: CLLocationManager, location: CLLocation, previousLocation: CLLocation?, activity: CMMotionActivity?, simulator: Bool) {
        reportStop()

        let speed = location.speed * 3.6
        let distance = previousLocation?.distance(from: location) ?? -1
        let duration = previousLocation == nil ? -1 : abs(previousLocation!.timestamp.timeIntervalSince(location.timestamp))
        let calculatedSpeed = calculateSpeed(between: location, and: previousLocation)
        let inAutomotive = activity?.automotive ?? false
        let unsure = .low == activity?.confidence ?? .low

        // NOTE: values configuration from algorithm spreadsheet
        let speedDefault: Double = 40
        let speedDivisor: Double = 40
        let speedSanity: Double = 10
        let calculatedDefault: Double = 17
        let calculatedDivisor: Double = 25
        let calculatedSanity: Double = 10
        let automotiveTrue: Double = 1
        let automotiveFalse: Double = 0.73
        let unsureTrue: Double = 0.69
        let unsureOff: Double = 1
        let bias: Double = 0.0001

        let value = 1.0 *
            (simulator ? 0 : 1) *
            min(1, ((speed > speedSanity ? speed : speedDefault) / speedDivisor)) *
            min(1, ((calculatedSpeed > calculatedSanity ? calculatedSpeed : calculatedDefault) / calculatedDivisor)) *
            (inAutomotive ? automotiveTrue : automotiveFalse) *
            (unsure ? unsureTrue : unsureOff) -
        bias

        DDLogDebug("values for determining driving state are, value=\(value) simulator=\(simulator) speed=\(speed) calculatedSpeed=\(calculatedSpeed) inAutomotive=\(inAutomotive) unsure=\(unsure) distance=\(distance) duration=\(duration) activity='\(String(describing: activity))'")

        let region = DriveDetectionRegion(center: location.coordinate)
        manager.startMonitoring(for: region)
        detection = DriveDetection(
            detecting: true,
            date: Date(),
            region: region,
            accuracy: location.horizontalAccuracy,
            state: value >= 0.5 ? .driving : .notDriving,
            permissionState: nil
        )

        didUpdate(detection)
        state = .waiting
        DDLogDebug("end background task=\(taskIdentifier ?? -1)")
        if let taskIdentifier = taskIdentifier {
            UIApplication.shared.endBackgroundTask(taskIdentifier)
        }
    }

    private func reportStop() {
        if abs(detection.date.timeIntervalSinceNow) > 900 && detection.state == .driving {
            DDLogDebug("retro-actively reporting a stop, state=\(state)")
            detection = detection.with(state: .notDriving)
            didUpdate(detection)
        }
    }

    private func prepareDetection() {
        taskIdentifier = UIApplication.shared.beginBackgroundTask {
            self.taskIdentifier = UIBackgroundTaskInvalid
        }
        DDLogDebug("begin background task=\(taskIdentifier ?? -1)")
    }
}

extension DriveDetector: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DDLogDebug("location manager callback status=\(status.readable) state=\(state)")
        switch status {
        case .authorizedAlways:
            guard state == .askForLocation else { return }
            state = .askForMotion

            let today = Date()
            motionManager.queryActivityStarting(from: today, to: today, to: motionQueue, withHandler: { _, error in
                DDLogDebug("motion manager query callback state=\(self.state)")
                self.motionManager.stopActivityUpdates()
                guard self.state == .askForMotion else { return }

                if let error = error {
                    switch CMError(rawValue: UInt32(error._code)) {
                    case CMErrorMotionActivityNotAuthorized:
                        fallthrough // swiftlint:disable:this no_fallthrough_only
                    case CMErrorNotAuthorized:
                        self.detection = self.detection.with(permissionState: .missingMotionActivity)
                    default:
                        self.state = .detecting
                    }
                } else {
                    self.state = .detecting
                }
                if self.state == .detecting {
                    self.detection = self.detection.with(detecting: true).with(permissionState: .all)
                    self.prepareDetection()
                    manager.startMonitoringSignificantLocationChanges()
                    manager.requestLocation()
                }
                self.didUpdate(self.detection)
            })
        default:
            detection = detection.with(permissionState: .missingLocation)
            didUpdate(detection)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if state == .detecting {
            if let location = locations.last {
                let validLocation = abs(location.timestamp.timeIntervalSinceNow) < maxLocationAge && location.horizontalAccuracy <= maxLocationInaccuracy
                guard validLocation || retryCount > maxRetryCount else {
                    DDLogDebug("no useable location, requesting a fresh location state=\(state) retryCount=\(retryCount) location=\(location)")
                    retryCount += 1
                    manager.requestLocation()
                    return
                }
                DDLogDebug("calculating values for detecting...")
                if Platform.isSimulator {
                    detect(manager: manager, location: location, previousLocation: previousLocation, activity: nil, simulator: true)
                    previousLocation = location
                } else {
                    motionManager.startActivityUpdates(to: motionQueue, withHandler: { activity in
                        self.motionManager.stopActivityUpdates()
                        self.detect(manager: manager, location: location, previousLocation: self.previousLocation, activity: activity, simulator: false)
                        self.previousLocation = location
                    })
                }
            } else {
                DDLogDebug("location manager did update locations without data during state=\(state)")
                manager.requestLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard state == .waiting else { return }
        state = .detecting
        prepareDetection()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DDLogError("location manager did fail with error=\(error.localizedDescription), state=\(state)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        DDLogError("location manager did fail monitoring with error=\(error.localizedDescription), region=\(String(describing: region)) state=\(state)")
    }
}

extension DriveDetector: DriveDetectorDelegate {
    func didUpdate(_ detection: DriveDetection) {
        DDLogDebug("did determine detection=\(detection)")
        for delegate in delegates {
            delegate.didUpdate(detection)
        }
    }
}

private struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
}

private extension CLAuthorizationStatus {
    var readable: String {
        switch self {
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        case .denied:
            return "denied"
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        }
    }
}

private enum DriveDetectorState {
    case idle, askForLocation, askForMotion, detecting, waiting
}

enum DriveDetectorPermissionState: Int {
    case all, missingLocation, missingMotionActivity
}

enum DriveDetectorDrivingState: Int {
    case driving, notDriving
}

class DriveDetectionRegion: CLCircularRegion {
    init(center: CLLocationCoordinate2D) {
        super.init(center: center, radius: 1000, identifier: "DriveDetector.regionIdentifier")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

struct DriveDetection {
    let detecting: Bool
    let date: Date
    let region: DriveDetectionRegion
    let accuracy: Double
    let state: DriveDetectorDrivingState
    let permissionState: DriveDetectorPermissionState?
}

extension DriveDetection: CustomStringConvertible {
    var description: String {
        return "Detection< detecting=\(detecting) date='\(date)' region='\(region)' accuracy=\(accuracy) state=\(state) permissionState=\(String(describing: permissionState)) >"
    }
}

extension DriveDetection {
    func with(permissionState: DriveDetectorPermissionState?) -> DriveDetection {
        return DriveDetection(
            detecting: detecting,
            date: date,
            region: region,
            accuracy: accuracy,
            state: state,
            permissionState: permissionState
        )
    }
    func with(state: DriveDetectorDrivingState) -> DriveDetection {
        return DriveDetection(
            detecting: detecting,
            date: date,
            region: region,
            accuracy: accuracy,
            state: state,
            permissionState: permissionState
        )
    }
    func with(detecting: Bool) -> DriveDetection {
        return DriveDetection(
            detecting: detecting,
            date: date,
            region: region,
            accuracy: accuracy,
            state: state,
            permissionState: permissionState
        )
    }
}
