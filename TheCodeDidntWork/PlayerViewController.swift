//
//  PlayerViewController.swift
//  TheCodeDidntWork
//
//  Created by EserLodhia on 06/07/23.
//

import AVFoundation
import UIKit
import OAuthSwift

class PlayerViewController: UIViewController {
    let oauthManager = OAuthManager()

    public var position: Int = 0
    public var songs: [Song] = []

    @IBOutlet var holder: UIView!

    var player: AVAudioPlayer?

    // User Interface elements

    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()

    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()

    let playPauseButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if holder.subviews.count == 0 {
            configure()
        }
    }

    func configure() {
        // set up player
        let song = songs[position]

        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")

        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            guard let urlString = urlString else {
                print("urlstring is nil")
                return
            }

            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)

            guard let player = player else {
                print("player is nil")
                return
            }
            player.volume = 0.5

            player.play()
        }
        catch {
            print("error occurred")
        }

        // set up user interface elements

        // album cover
        albumImageView.frame = CGRect(x: 10,
                                      y: 10,
                                      width: holder.frame.size.width-20,
                                      height: holder.frame.size.width-20)
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)

        // Labels: Song name, album, artist
        songNameLabel.frame = CGRect(x: 10,
                                     y: albumImageView.frame.size.height + 10,
                                     width: holder.frame.size.width-20,
                                     height: 70)
        albumNameLabel.frame = CGRect(x: 10,
                                     y: albumImageView.frame.size.height + 10 + 70,
                                     width: holder.frame.size.width-20,
                                     height: 70)
        artistNameLabel.frame = CGRect(x: 10,
                                       y: albumImageView.frame.size.height + 10 + 140,
                                       width: holder.frame.size.width-20,
                                       height: 70)

        songNameLabel.text = song.name
        albumNameLabel.text = song.albumName
        artistNameLabel.text = song.artistName

        holder.addSubview(songNameLabel)
        holder.addSubview(albumNameLabel)
        holder.addSubview(artistNameLabel)

        // Player controls
        let nextButton = UIButton()
        let backButton = UIButton()

        // Frame
        let yPosition = artistNameLabel.frame.origin.y + 70 + 20
        let size: CGFloat = 70

        playPauseButton.frame = CGRect(x: (holder.frame.size.width - size) / 2.0,
                                       y: yPosition,
                                       width: size,
                                       height: size)

        nextButton.frame = CGRect(x: holder.frame.size.width - size - 20,
                                  y: yPosition,
                                  width: size,
                                  height: size)

        backButton.frame = CGRect(x: 20,
                                  y: yPosition,
                                  width: size,
                                  height: size)

        // Add actions
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        // Styling

        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        backButton.setBackgroundImage(UIImage(systemName: "backward.fill"), for: .normal)
        nextButton.setBackgroundImage(UIImage(systemName: "forward.fill"), for: .normal)

        playPauseButton.tintColor = .black
        backButton.tintColor = .black
        nextButton.tintColor = .black

        holder.addSubview(playPauseButton)
        holder.addSubview(nextButton)
        holder.addSubview(backButton)

        // slider
        let slider = UISlider(frame: CGRect(x: 20,
                                            y: holder.frame.size.height-60,
                                            width: holder.frame.size.width-40,
                                            height: 50))
        slider.value = 0.5
        slider.addTarget(self, action: #selector(didSlideSlider(_:)), for: .valueChanged)
        holder.addSubview(slider)
    }

    @objc func didTapBackButton() {
        if position > 0 {
            position = position - 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }

    @objc func didTapNextButton() {
        if position < (songs.count - 1) {
            position = position + 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }

    @objc func didTapPlayPauseButton() {
        if player?.isPlaying == true {
            // Pause
            player?.pause()
            // Show play button
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            
            // Shrink image
            UIView.animate(withDuration: 0.2) {
                self.albumImageView.frame = CGRect(x: 30,
                                                    y: 30,
                                                    width: self.holder.frame.size.width - 60,
                                                    height: self.holder.frame.size.width - 60)
            }
        } else {
            // Play
            oauthManager.authorize { accessToken, accessTokenSecret in
                if let accessToken = accessToken, let accessTokenSecret = accessTokenSecret {
                    // Authorization successful
                    // Use the access token and secret in your API requests
                    
                    if let sessionID = UIDevice.current.identifierForVendor?.uuidString {
                        self.playTrack(trackID: self.songs[self.position].trackID, session: sessionID)
                    } else {
                        print("Unable to generate session ID")
                    }
                } else {
                    // Authorization failed
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Authorization Failed", message: "Unable to authorize with Audiomack. Please try again later.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            // Increase image size
            UIView.animate(withDuration: 0.2) {
                self.albumImageView.frame = CGRect(x: 10,
                                                    y: 10,
                                                    width: self.holder.frame.size.width - 20,
                                                    height: self.holder.frame.size.width - 20)
            }
        }
    }


    @objc func didSlideSlider(_ slider: UISlider) {
        let value = slider.value
        player?.volume = value
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.stop()
        }
    }
    
    //
    
    func playTrack(trackID: String, session: String?) {
        let baseURL = "https://api.audiomack.com/v1/music/"
        let urlString = baseURL + trackID + "/play"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add optional parameters
        if let session = session {
            request.setValue(session, forHTTPHeaderField: "session")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let options = JSONSerialization.ReadingOptions.allowFragments
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: options) as? [String: Any],
                   let streamURLString = responseJSON["streamingURL"] as? String,
                   let streamURL = URL(string: streamURLString) {
                    // Play the track using AVAudioPlayer or any other audio player library
                    self.playAudioFromURL(streamURL)
                } else {
                    print("Invalid response")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }


    func playAudioFromURL(_ url: URL) {
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else {
                print("Player is nil")
                return
            }
            
            player.volume = 0.5
            player.play()
        } catch {
            print("Error occurred: \(error)")
        }
    }


}
