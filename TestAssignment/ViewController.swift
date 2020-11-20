//
//  ViewController.swift
//  TestAssignment
//
//  Created by Андрей Гедзюра on 19.11.2020.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var albumCollection: UICollectionView!
    private let numberOfCells = 3
    /**Search task for timing control.*/
    private var searchTask: DispatchWorkItem?
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Result> = {
        let dataSource = UICollectionViewDiffableDataSource<Int, Result>(collectionView: albumCollection) { (collectionView, indexPath, result) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell
            cell?.album = result
            return cell
        }
        return dataSource
    }()
    
    // MARK: - View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        albumCollection.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "AlbumCell")
        albumCollection.delegate = self
        APIHandler.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureSearchControllerAppeared()
    }
    /**Configures search controller before view appearance.*/
    private func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Albums"
        searchController.searchBar.scopeButtonTitles = []
        APIHandler.Key.allCases.forEach({
            switch $0 {
            case .albumName:
                searchController.searchBar.scopeButtonTitles?.append("Album")
            case .artistName:
                searchController.searchBar.scopeButtonTitles?.append("Artist")
            }
        })
        navigationItem.searchController = searchController
    }
    /**Configuress search controller after view appearance.*/
    private func configureSearchControllerAppeared() {
        if let searchTextField = navigationItem.searchController?.searchBar.searchTextField, let clearButton = searchTextField.value(forKey: "_clearButton") as? UIButton, let glassIcon = searchTextField.leftView as? UIImageView {
            searchTextField.textColor = UIColor(named: "reversed")
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Albums", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "reversed pale") ?? UIColor.black])
           // Create a template copy of the original button image
            glassIcon.image = glassIcon.image?.withRenderingMode(.alwaysTemplate)
            glassIcon.tintColor = UIColor(named: "reversed pale")
            let templateImage =  clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
           // Set the template image copy as the button image
            clearButton.setImage(templateImage, for: .normal)
           // Finally, set the image color
           clearButton.tintColor = UIColor(named: "reversed pale")
        }
        navigationItem.searchController?.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "reversed") ?? UIColor.white], for: .normal)
    }
    /**Submits changing both in data source and collection view.*/
    private func applySnapshot(with items: [Result], animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Result>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

    // MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newVC = storyboard?.instantiateViewController(identifier: "DetailedViewController") as? DetailedViewController
        newVC?.album = dataSource.itemIdentifier(for: indexPath)
        navigationController?.pushViewController(newVC ?? UIViewController(), animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize.zero
        }
        //Calculating cell size, 38 is the sum of all vertical constraints and heights of two UILabels in Album cell
        let width = (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing * CGFloat(numberOfCells - 1)) / CGFloat(numberOfCells)
        return CGSize(width: width, height: width + 38)
    }
}

    // MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            searchTask?.cancel()
            applySnapshot(with: [])
            return
        }
        var filter: APIHandler.Key
        switch searchController.searchBar.scopeButtonTitles?[searchController.searchBar.selectedScopeButtonIndex] {
        case "Album":
            filter = .albumName
        case "Artist":
            filter = .artistName
        default:
            return
        }
        //Creating search task
        searchTask?.cancel()
        searchTask = DispatchWorkItem {
            APIHandler.shared.getAlbums(searchString: query, key: filter, completionHandler: {result in
                //Sorting result in order when first appear items with name equal to query and in alphabetical order. Other items are sorted also in alphabetical order.
                let sortedResult = result.sorted { (first, second) -> Bool in
                    switch filter {
                    case .albumName:
                        switch (first.collectionName.lowercased() == query.lowercased(), second.collectionName.lowercased() == query.lowercased(), first.collectionName.lowercased() < second.collectionName.lowercased()) {
                        case (true, true, true), (true, false, false), (true, false, true), (false, false, true):
                            return true
                        default:
                            return false
                        }
                    case .artistName:
                        switch (first.artistName.lowercased() == query.lowercased(), second.artistName.lowercased() == query.lowercased(), first.collectionName.lowercased() < second.collectionName.lowercased()) {
                        case (true, false, false), (true, false, true), (true, true, true), (false, false, true):
                            return true
                        default:
                            return false
                        }
                    }
                }
                
                self.applySnapshot(with: sortedResult)
            })
        }
        //Assignin search task with delay to make it possible to wait some time between character input. It reduces amount of server requests.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: searchTask ?? DispatchWorkItem(block: {}))
    }
}
