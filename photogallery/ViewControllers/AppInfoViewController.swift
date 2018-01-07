//
//  AppInfoViewController.swift
//  photoGallery
//
//  Created by Arup Saha on 11/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

final class AppInfoViewController: BaseViewController {
    @IBOutlet fileprivate weak var tableView: PGTableView! {
        didSet {
            tableView.register(UINib(nibName: AppInfoTableViewCell.className, bundle: Bundle.main) , forCellReuseIdentifier: AppInfoTableViewCell.className)
            tableView.rowHeight = 70
        }
    }
    fileprivate var viewModel: AppInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PGConstants.Strings.credits.localized
        bindToRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    convenience init(viewModel: AppInfoViewModel) {
        self.init()
        self.viewModel = viewModel
    }
}

extension AppInfoViewController {
    func bindToRx() {
        viewModel.infoDriver
            .asObservable().bind(to: tableView.rx.items(cellIdentifier: AppInfoTableViewCell.className, cellType: AppInfoTableViewCell.self)) { (_, item, cell) in
                cell.titleText = item.title
                cell.descriptionText = item.description
        }
        .addDisposableTo(disposeBag)
    }
}
