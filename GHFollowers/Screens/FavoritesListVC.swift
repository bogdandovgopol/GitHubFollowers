//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Bogdan on 13/9/20.
//  Copyright © 2020 Bogdan. All rights reserved.
//

import UIKit

class FavoritesListVC: GFDataLoadingVC {
    
    let tableView = UITableView()
    var favorites = [Follower]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
        getFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        tableView.removeExcessCells()
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reusableID)
    }

    func getFavorites() {
        PersistanceManager.retrieveFavorites { [weak self](result) in
            guard let self = self else { return }
            switch result {
            case .success(let favorites):
                self.updateUI(with: favorites)
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went worng", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }

    func updateUI(with favorites: [Follower]) {
        if favorites.isEmpty {
            self.showEmptyStateView(with: "You have no favorites\n Add on the follower screen.", in: self.view)
        } else {
            self.favorites = favorites
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
}

extension FavoritesListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reusableID) as! FavoriteCell
        cell.set(favorite: favorites[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destVC = FollowerListVC(username: favorite.login)
        
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistanceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self](error) in
            guard let self = self else { return }
            guard let error = error else {
                self.favorites.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                return
            }
            self.presentGFAlertOnMainThread(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok")
        }
    }
}
