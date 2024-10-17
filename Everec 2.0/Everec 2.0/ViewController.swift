import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordings: [(name: String, filePath: URL)] = []
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func record(_ sender: Any) {
        if audioRecorder == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let currentDateString = dateFormatter.string(from: Date())
            let fileName = "Recording_\(currentDateString).m4a"
            let filePath = getDirectory().appendingPathComponent(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                buttonLabel.setTitle("Stop Recording", for: .normal)
            } catch {
                displayAlert(title: "Oops", message: "Recording Failed")
            }
        } else {
            audioRecorder.stop()
            audioRecorder = nil
            
            // Save the filename and date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentDateString = dateFormatter.string(from: Date())
            recordings.append((name: ":)  \(currentDateString)", filePath: getDirectory().appendingPathComponent("Recording_\(currentDateString.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: ":", with: "-")).m4a")))
            UserDefaults.standard.setValue(recordings.map { ["name": $0.name, "filePath": $0.filePath.absoluteString] }, forKey: "myRecordings")
            
            myTableView.reloadData()
            buttonLabel.setTitle("Start Recording", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        if let savedRecordings = UserDefaults.standard.object(forKey: "myRecordings") as? [[String: String]] {
            recordings = savedRecordings.map { (name: $0["name"]!, filePath: URL(string: $0["filePath"]!)!) }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("Accepted")
            }
        }
        
        myTableView.delegate = self
        myTableView.dataSource = self
    }
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let recording = recordings[indexPath.row]
        cell.textLabel?.text = recording.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recording = recordings[indexPath.row]
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.filePath)
            audioPlayer.play()
        } catch {
            displayAlert(title: "Oops!", message: "Playback Failed")
        }
    }
}

