//
//  GameCenterView.swift
//  NFLSers-iOS
//
//  Created by hqy on 2017/10/3.
//  Copyright © 2017年 胡清阳. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class GameCenterViewController:UITableViewController{
    
    var names = [String]()
    var descriptions = [String]()
    var urls = [String]()
    var images = [String]()
    
    func loadFromLocal(){
        if(UserDefaults.standard.value(forKey: "game_names") as? [String]) != nil{
            names = UserDefaults.standard.value(forKey: "game_names") as! [String]
            urls = UserDefaults.standard.value(forKey: "game_urls") as! [String]
            descriptions = UserDefaults.standard.value(forKey: "game_descriptions") as! [String]
            images = UserDefaults.standard.value(forKey: "game_img") as! [String]
            tableView.reloadData()
        }
    }
    func setUpUI(){
        let theme = ThemeManager()
        self.navigationController?.navigationBar.barStyle = theme.gameTheme.style
        self.navigationController?.navigationBar.barTintColor = theme.gameTheme.titleBackgroundColor
        self.navigationController?.navigationBar.tintColor = theme.gameTheme.titleButtonColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:theme.gameTheme.titleButtonColor ?? UIColor.black]
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: theme.gameTheme.titleButtonColor ?? UIColor.black
            ]
        }
    }

    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    override func viewDidLoad() {
        setUpUI()
        loadFromLocal()
        Alamofire.request("https://api.nfls.io/game/list").responseJSON { response in
            switch(response.result){
            case .success(let json):
                
                let info = ((json as! [String:AnyObject])["info"] as! [[String:Any]])
                self.names.removeAll()
                self.descriptions.removeAll()
                self.urls.removeAll()
                self.images.removeAll()
                for detail in info {
                    self.names.append(detail["name"] as! String)
                    self.descriptions.append(detail["description"] as! String)
                    self.urls.append(detail["url"] as! String)
                    self.images.append(detail["icon"] as! String)
                }
                UserDefaults.standard.set(self.names, forKey: "game_names")
                UserDefaults.standard.set(self.urls, forKey: "game_urls")
                UserDefaults.standard.set(self.descriptions, forKey:"game_descriptions")
                UserDefaults.standard.set(self.images, forKey:"game_img")
                self.tableView.reloadData()
                break
            default:
                break
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Notice: You must run the game at least once with internet connection in order to enable its offline mode."
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath)
        
        cell.textLabel?.text = names[indexPath.row]
        cell.accessibilityElementsHidden = true
        cell.detailTextLabel?.text = descriptions[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        cell.imageView?.kf.setImage(with: URL(string: images[indexPath.row]), placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
            cell.imageView?.image = image!.kf.resize(to: CGSize(width: 50, height: 50))
        })
        cell.textLabel!.font = UIFont(name: "HelveticaBold", size: 18)
        cell.detailTextLabel!.font = UIFont(name: "Helvetica", size: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showGame", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as! Int
        let dest = segue.destination as! GameViewController
        dest.location = urls[index]
        dest.name = names[index]
        dest.id = index + 1
    }
    
}
