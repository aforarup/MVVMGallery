//
//  CoreDataUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import CoreData

protocol ImagePersistable {
    func loadData() -> [ImageData]
    func saveData(_ data: ImageData)
}

final class CoreDataImageNameUtility: ImagePersistable {
    fileprivate let appDelegate: AppDelegate
    
    init() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    }
    
    func loadData() -> [ImageData] {
        let fetchRequest = NSFetchRequest<Image>(entityName: "Image")
        do {
            return try appDelegate.persistentCoordinator.viewContext.fetch(fetchRequest).flatMap({ ImageData(shared: $0.shared, image: nil, name: $0.name!) })
        } catch {
            return []
        }
    }
    
    func saveData(_ data: ImageData) {
        if data.shared {
            let fetchRequest = NSFetchRequest<Image>(entityName: "Image")
            fetchRequest.predicate = NSPredicate(format: "name = %@", data.name)
            do {
                let fetchResults = try appDelegate.persistentCoordinator.viewContext.fetch(fetchRequest)
                fetchResults.first?.setValue(data.shared, forKey: "shared")
            } catch {
                return
            }
        } else {
            let entity = Image(context: appDelegate.persistentCoordinator.viewContext)
            entity.name = data.name
            entity.shared = data.shared
        }
        appDelegate.saveContext()
    }
    
}
