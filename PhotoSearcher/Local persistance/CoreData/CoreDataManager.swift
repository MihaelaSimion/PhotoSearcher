//
//  CoreDataManager.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import CoreData
import Foundation

class CoreDataManager {
  private var mainContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  private var successfulSearchesResultsController: NSFetchedResultsController<SuccessfulSearch>?

  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "PhotoSearcher")
    container.loadPersistentStores(completionHandler: { storeDescription, error in
      if let error = error as NSError? {
        print("Unresolved error \(error)")
      }
    })
    return container
  }()

  private func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print("Unable to save changes in context.")
      }
    }
  }

  private func getBasicFetchRequest(predicate: NSPredicate?) -> NSFetchRequest<SuccessfulSearch> {
    let fetchRequest = NSFetchRequest<SuccessfulSearch>(entityName: "SuccessfulSearch")
    let sortingDescriptor = NSSortDescriptor(key: "searchDate", ascending: false)
    fetchRequest.sortDescriptors = [sortingDescriptor]
    if let predicate = predicate {
      fetchRequest.predicate = predicate
    }

    return fetchRequest
  }

  private func fetchSuccessfulSearches(predicate: NSPredicate? = nil) -> [SuccessfulSearch]? {
    let request = getBasicFetchRequest(predicate: predicate)
    successfulSearchesResultsController = NSFetchedResultsController(fetchRequest: request,
                                                                     managedObjectContext: mainContext,
                                                                     sectionNameKeyPath: nil,
                                                                     cacheName: nil)
    do {
      try successfulSearchesResultsController?.performFetch()
      return successfulSearchesResultsController?.fetchedObjects
    } catch {
      return nil
    }
  }

  private func existingSearchWith(query: String) -> SuccessfulSearch? { // to not save duplicates
    let predicate = NSPredicate(format: "query == [c] %@", query)
    let existingSearch = fetchSuccessfulSearches(predicate: predicate)?.first

    return existingSearch
  }
}

extension CoreDataManager: SuccessfulSearchHandler {
  func fetchSearchQueries() -> [String] {
    guard let searches = fetchSuccessfulSearches() else { return [] }
    let queries = searches.compactMap { search in
      return search.query
    }
    return queries
  }

  func saveSearch(query: String) {
    if let existingSearch = existingSearchWith(query: query) {
      existingSearch.searchDate = Date()
      saveContext()
    } else {
      let succesfulSearch = SuccessfulSearch(context: mainContext)
      succesfulSearch.query = query
      succesfulSearch.searchDate = Date()
      saveContext()
    }
  }

  func keepOnlyLastTenSearches() {
    guard let searches = fetchSuccessfulSearches() else { return }
    if searches.count > 10,
       let oldestItem = searches.last {
      mainContext.delete(oldestItem)
      saveContext()
    }
  }
}
