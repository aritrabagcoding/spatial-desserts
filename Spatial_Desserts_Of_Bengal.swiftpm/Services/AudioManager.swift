import AVFoundation
import SwiftUI
import AudioToolbox
import Observation

@MainActor
@Observable
class AuMgr {
    static let shared = AuMgr()
    var p: AVAudioPlayer?
    var isMuted: Bool = false
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleInterruption(note: Notification) {
        guard let info = note.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        if type == .began {
            p?.pause()
        } else if type == .ended {
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) && !isMuted {
                    p?.play()
                }
            }
        }
    }
    
    func playBGM() {
        if isMuted { return }
        guard let url = Bundle.main.url(forResource: "bgm", withExtension: "m4a") else {
            print("Error: bgm.m4a not found in bundle.")
            return
        }
        
        if p == nil {
            do {
                p = try AVAudioPlayer(contentsOf: url)
                p?.numberOfLoops = -1
                p?.prepareToPlay()
            } catch {
                print("Audio Player Error: \(error)")
            }
        }
        p?.play()
    }
    
    func pauseBGM() {
        p?.pause()
    }
    
    func resumeBGM() {
        if !isMuted {
            p?.play()
        }
    }
    
    func toggleMute(_ mute: Bool) {
        isMuted = mute
        if mute {
            p?.stop()
        } else {
            playBGM()
        }
    }
    
    func setVolume(_ value: Float) {
        if value > 0 && isMuted {
            isMuted = false
            p?.play()
        }
        p?.volume = value
    }
    
    
}

