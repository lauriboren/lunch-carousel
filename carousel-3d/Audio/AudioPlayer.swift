import AVFoundation

class AudioPlayer {
    private let numPlayers = 16
    private var engine: AVAudioEngine!
    private var players = [AVAudioPlayerNode]()
    private var buffer: AVAudioPCMBuffer!
    
    init() {
        engine = AVAudioEngine()
        for _ in 0..<numPlayers {
            players.append(AVAudioPlayerNode())
        }
        guard ((try? AVAudioSession.sharedInstance().setCategory(.playback)) != nil) else {
            print("AudioPlayer ERROR: Couldn't set AVAudioSession category")
            return
        }
        
        let path = Bundle.main.path(forResource: "click.caf", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        guard let file = try? AVAudioFile(forReading: url) else {
            print("AudioPlayer ERROR: Couldn't read file")
            return
        }
        buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
        guard buffer != nil else {
            print("AudioPlayer ERROR: Couldn't create buffer")
            return
        }
        try? file.read(into: buffer)
        
        for player in players {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: buffer.format)
        }
        
        engine.prepare()
        guard ((try? engine.start()) != nil) else {
            print("AudioPlayer ERROR: Couldn't start engine")
            return
        }
    }
    
    private var nextPlayer = 0
    func play() {
        guard engine.isRunning else {
            print("AudioPlayer ERROR: Audio engine seems to not be running")
            return
        }
        let playerIndex = nextPlayer
        nextPlayer = (nextPlayer + 1) % numPlayers
        players[playerIndex].scheduleBuffer(buffer)
        players[playerIndex].play()
    }
}
