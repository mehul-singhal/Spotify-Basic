//
//  ListViewController.swift
//  Spotify-Basic
//
//  Created by Mehul  Singhal  on 07/07/17.
//  Copyright © 2017 Mehul  Singhal . All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation


var player = AVAudioPlayer()

var holderOfurl : String!

struct post {
    let image : UIImage!
    let name : String!
}

struct urlholder
{
    let previewURL : String!
}

var albumArt : UIImage!

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UITableView!
    
    var searchURL = String()
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!)"
        callAlamo(url: searchURL)
        tableView.reloadData()
        self.view.endEditing(true)

    }
    
    var posts = [post]()
    
    var green = [urlholder]()
    
    typealias JSONstandards = [String: AnyObject]
    
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callAlamo(url: String)
    {
        
        let parameters = ["type":"track"]
        let headers = ["Accept":"application/json", "Authorization":"Bearer BQCGU8fdkpF154bWFKjuBGejDHK6icK7delaPZHlNKMG-cnv-jIoSLkmpKVHQFLac-agyP7SOyT3Ye8z2X6nP0Oy6piHyroILRcmktMJy4kUsEMW1HC8AF5Jbrg9HYcySVYKTGk1EoWEhtyDy8dVHCPUJkposx6VYinQhp9HiTPYpcvl6nXS8SrGKeLfnl7uIyiSLkscdCPiB8QhmUrW469X_UU0BsyB1N54UOimVs7Mde4xVCC9OeXpSqdGVQm2F8E-IgMcBwMXloL_NsnjUevZgRo_XLIBfQzKuFyMM0YIV6_8FTXcC11wkdIoXI8gzm8" ]
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers).response(completionHandler:{
            
            response in
            
            self.parseData(JSONdata: response.data!)
            
        })
    }
    
    
    func parseData (JSONdata: Data)
    {
        
        do{
            var readAbleJSON = try JSONSerialization.jsonObject(with: JSONdata, options: .mutableContainers) as! JSONstandards
            //print(readAbleJSON)
            if let expiredToken = readAbleJSON["error"] as? JSONstandards
            {
                let optionMenu = UIAlertController(title: nil, message: "The Token has been expired. Contact developer.", preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                optionMenu.addAction(cancelAction)
                present(optionMenu, animated: true, completion: nil)
            }
            else{
            if let tracks =  readAbleJSON["tracks"] as? JSONstandards{
                if let items = tracks["items"] as? [JSONstandards]{
                    for i in 0..<items.count{
                        let item = items[i]
                        
                        let name = item["name"] as! String
                        if let urlTemp = item["preview_url"] as? String
                        {
                           
                            holderOfurl = item["preview_url"] as! String!
                        }
                        else
                        {
                            holderOfurl = "sdfjklasdjlf"
                            
                        }

                        if let album = item["album"] as? JSONstandards{
                            
                            if let images = album["images"] as? [JSONstandards]{
                                let myImage = images[0]
                                let myImageURL = URL(string: myImage["url"] as! String)
                                
                                let myImageData = NSData(contentsOf: myImageURL!)
                                
                                let mainImage = UIImage(data: myImageData as! Data)
                                
                                albumArt = mainImage
                            }
                        }
                        posts.append(post.init(image: albumArt, name: name))
                        green.append(urlholder.init(previewURL: holderOfurl))
                        print(posts[0])
                        self.tableView.reloadData()
                    }
                    }
                    
                }
            }
        }
        catch{
            print(error)
        }
    }  
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print(posts.count)
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = posts[indexPath.row].image
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 45
        //print(posts[indexPath.row].image)
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = posts[indexPath.row].name
        //print(posts[indexPath.row].name)
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let vc = segue.destination as! AudioVC
        
        vc.image = posts[indexPath!].image
        vc.mainSongTitle = posts[indexPath!].name
        vc.mainSongURL = green[indexPath!].previewURL
    }
    
    override var prefersStatusBarHidden: Bool
        {
        
        return true
    }
    
}
    

    

   


