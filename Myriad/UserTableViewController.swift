//
//  UserTableViewController.swift
//  Myriad
//
//  Created by Omar Finol-Evans on 8/2/18.
//  Copyright © 2018 Omar Finol-Evans. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {

    var usernames = [""]
    var objIds = [""]
    
    var isFollowing = ["" : true]
    
    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let query = PFUser.query()
        
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        
        query?.findObjectsInBackground(block: { (objs, error) in
            if error != nil {
                print(error)
            } else if let users = objs {
                self.usernames.removeAll()
                self.objIds.removeAll()
                self.isFollowing.removeAll()
                for obj in users {
                    if let user = obj as? PFUser {
                        if let username = user.username {
                            
                            let usernameArray = username.components(separatedBy: "@")
                            
                            self.usernames.append(usernameArray[0])
                            if let objId = user.objectId {
                                self.objIds.append(objId)
                                let query = PFQuery(className: "Following")
                                query.whereKey("folowers", equalTo: PFUser.current()?.objectId)
                                query.whereKey("followings", equalTo: objId)
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if let objects = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objId] = true
                                        } else {
                                            self.isFollowing[objId] = false
                                        }
                                        self.tableView.reloadData()
                                    }

                                })
                            }
                        }
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        if let doesFollow = isFollowing[objIds[indexPath.row]] {
            if doesFollow {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let doesFollow = isFollowing[objIds[indexPath.row]] {
            if doesFollow {
                cell?.accessoryType = UITableViewCellAccessoryType.none
                
                let query = PFQuery(className: "Following")
                query.whereKey("folowers", equalTo: PFUser.current()?.objectId)
                query.whereKey("followings", equalTo: objIds[indexPath.row])
                
                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                    }
                })
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                let following = PFObject(className: "Following")
                following["followers"] = PFUser.current()?.objectId
                following["followings"] = objIds[indexPath.row]
                
                following.saveInBackground()
                
            }
        }
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
