//
//  Model.swift
//  EngEn
//
//  Created by Loaner on 3/21/23.
//

import Foundation
import CoreData
import UIKit
import Combine
import MapKit
import FlagKit
import AVFoundation
import Foundation
import Speech
import OpenAISwift
import EventKit
import UserNotifications


func importJsonConData() {
    let context = PersistenceController.shared.container.viewContext
    let request = NSFetchRequest<Contacts>(entityName: "Contacts")
    
    //                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contacts")
    //                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    //
    //                        do {
    //                            try context.execute(deleteRequest)
    //                            try context.save()
    //                        } catch let error as NSError {
    //                            print("Error deleting data from Contacts entity: \(error)")
    //                        }
    
    let count = try? context.count(for: request)
    guard count == 0 else {
        // Data has already been imported
        return
    }
    
    guard let url = Bundle.main.url(forResource: "Contacts", withExtension: "json") else {
        print("Error: could not find Contacts.json")
        return
    }
    guard let data = try? Data(contentsOf: url) else {
        print("Error: could not load Contacts.json")
        return
    }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        print("Error: could not parse Contacts.json")
        return
    }
    for entry in json {
        let object = Contacts(context: context)
        object.firstName = entry["First Name"] as? String
        object.lastName = entry["Last Name"] as? String
        object.city = entry["City"] as? String
        object.state = entry["State"] as? String
        object.country = entry["Country"] as? String
        object.email = entry["Email"] as? String
        object.phone = entry["Phone"] as? String
        object.notes = entry["Nots"] as? String
        object.flag = stringFromImage(Flag(countryCode: getISO2(forCountry: object.country!, in: GeoData())!)!.originalImage)
        try? context.save()
    }
}

func loadJsonGeoData() {
    let context = PersistenceController.shared.container.viewContext
    let request = NSFetchRequest<City>(entityName: "City")
    let count = try? context.count(for: request)
    guard count == 0 else {
        // Data has already been imported
        return
    }
    guard let url = Bundle.main.url(forResource: "GeoInfo", withExtension: "json") else {
        print("Error: could not find GeoInfo.json")
        return
    }
    guard let data = try? Data(contentsOf: url) else {
        print("Error: could not load GeoInfo.json")
        return
    }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        print("Error: could not parse GeoInfo.json")
        return
    }
    for entry in json {
        let city = City(context: context)
        city.city = entry["city"] as? String
        city.city_ascii = entry["city_ascii"] as? String
        city.lat = entry["lat"] as? Double ?? 0
        city.lng = entry["lng"] as? Double ?? 0
        city.country = entry["country"] as? String
        city.iso2 = entry["iso2"] as? String
        city.iso3 = entry["iso3"] as? String
        city.admin_name = entry["admin_name"] as? String
        try? context.save()
    }
}


let avatar = UIImage(named: "contact-photo")//"user-avatar-glad"
let user_photo = UIImage(named: "user-photo")

func imageFromString(_ strPic: String?) -> UIImage {
    var picImage: UIImage?
    if let strPic = strPic {
        let picImageData = Data(base64Encoded: strPic, options: .ignoreUnknownCharacters)
        picImage = UIImage(data: picImageData!)
    } else {
        picImage = avatar
    }
    return picImage ?? avatar!
}

func stringFromImage(_ imagePic: UIImage) -> String {
    let picImageData: Data = imagePic.jpegData(compressionQuality: 0.5)!
    let picBase64 = picImageData.base64EncodedString()
    return picBase64
}

func searchCity(city: String, country: String, state: String?) -> [City] {
    let request: NSFetchRequest<City> = City.fetchRequest()
    
    var predicates = [NSPredicate]()
    
    predicates.append(NSPredicate(format: "city == %@", city))
    predicates.append(NSPredicate(format: "country == %@", country))
    
    if country == "United States" {
        if let state = state {
            predicates.append(NSPredicate(format: "admin_name CONTAINS %@", state))
        }
    }
    
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    
    let context = PersistenceController.shared.container.viewContext
    
    do {
        let result = try context.fetch(request)
        return result
    } catch let error {
        print("Error fetching cities: \(error.localizedDescription)")
        return []
    }
}

func addContact(person: NewContactData, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let firstName = person.firstName, !firstName.isEmpty,
          let lastName = person.lastName, !lastName.isEmpty,
          let city = person.city, !city.isEmpty,
          let state = person.state, !state.isEmpty,
          let country = person.country, !country.isEmpty
    else {
        showAlert(title: "Error", message: "Please fill in all required fields.")
        completion(.failure(ContactError.missingData))
        return
    }
    
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "firstName == %@ AND lastName == %@ AND city == %@ AND state == %@ AND country == %@", firstName, lastName, city, state, country)
    
    do {
        let contacts = try context.fetch(fetchRequest)
        if contacts.count > 0 {
            showAlert(title: "Error", message: "A contact with the same name and location already exists.")
            completion(.failure(ContactError.duplicateContact))
            return
        }
        
        let newContact = Contacts(context: context)
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.state = state.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.country = country.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.lng = person.lng
        newContact.lat = person.lat
        newContact.picture = stringFromImage(person.picture ?? avatar!)
        newContact.email = person.email
        newContact.phone = person.phone
        newContact.notes = person.notes
        newContact.flag = stringFromImage(Flag(countryCode: getISO2(forCountry: newContact.country!, in: GeoData())!)!.originalImage)
        
        try context.save()
        
        showAlert(title: "Success!", message: "Contact saved successfully.")
        completion(.success(()))
    } catch {
        print("Error saving contact: \(error.localizedDescription)")
        showAlert(title: "Error", message: "Contact could not be saved.")
        completion(.failure(error))
    }
}

func showAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
        rootViewController.present(alertController, animated: true, completion: nil)
    }
}


enum ContactError: Error {
    case missingData
    case duplicateContact
}



func editContact(person: NewContactData, newContact: Contacts, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let firstName = person.firstName, !firstName.isEmpty,
          let lastName = person.lastName, !lastName.isEmpty,
          let city = person.city, !city.isEmpty,
          let state = person.state, !state.isEmpty,
          let country = person.country, !country.isEmpty
    else {
        showAlert(title: "Error", message: "Please fill in all required fields.")
        completion(.failure(ContactError.missingData))
        return
    }
    
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "firstName == %@ AND lastName == %@ AND city == %@ AND state == %@ AND country == %@", firstName, lastName, city, state, country)
    
    do {
        if firstName != newContact.firstName || lastName != newContact.lastName || city != newContact.city || country != newContact.country || state != newContact.state {
            let contacts = try context.fetch(fetchRequest)
            if contacts.count > 0 {
                showAlert(title: "Error", message: "A contact with the same name and location already exists.")
                completion(.failure(ContactError.duplicateContact))
                return
            }
        }
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.state = state.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.country = country.trimmingCharacters(in: .whitespacesAndNewlines)
        newContact.lng = person.lng
        newContact.lat = person.lat
        newContact.picture = stringFromImage(person.picture ?? avatar!)
        newContact.email = person.email
        newContact.phone = person.phone
        newContact.notes = person.notes
        newContact.flag = stringFromImage(Flag(countryCode: getISO2(forCountry: newContact.country!, in: GeoData())!)!.originalImage)
        
        try context.save()
        
        showAlert(title: "Success!", message: "Contact saved successfully.")
        completion(.success(()))
    } catch {
        print("Error saving contact: \(error.localizedDescription)")
        showAlert(title: "Error", message: "Contact could not be saved.")
        completion(.failure(error))
    }
}




class MapAPI: ObservableObject{
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "e32680c9d1b0d20e33b5dbfc55cb2deb"
    
    @Published var region: MKCoordinateRegion
    @Published var locations: [Location] = []
    
    init() {
        // Default Info
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
        
        self.locations.append(Location(name: "Pin", region: "", country: "", latitude: 51.507222, longitude: -0.1275))
    }
    
    // API request
    func getLocations(query: String, completion: @escaping ([String]) -> Void) {
        let pQuery = query.replacingOccurrences(of: " ", with: "%20")
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pQuery)&limit=10"
        
        guard let url = URL(string: url_string) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                completion([])
                return
            }
            
            guard let address = try? JSONDecoder().decode(Address.self, from: data) else {
                print("Failed to decode response")
                completion([])
                return
            }
            
            if address.data.isEmpty {
                print("Could not find any matches for query: \(query)")
                completion([])
                return
            }
            
            let locations = address.data.map { data in
                "\(data.name ?? ""), \(data.region ?? ""), \(data.country ?? ""), \(data.latitude ), \(data.longitude )"
            }
            
            completion(locations)
        }
        .resume()
    }
}


func getISO2(forCountry country: String, in geoData: GeoData) -> String? {
    for city in geoData.cities {
        if let cityCountry = city.country, cityCountry == country, let iso2 = city.iso2 {
            return iso2
        }
    }
    
    print("Country not found")
    return nil
}
// Code for speach recognition and transcribe is tacken from apple tutorial
class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    init() {
        recognizer = SFSpeechRecognizer()
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    func transcribe() {
        DispatchQueue(label: "Speech Recognizer Queue", qos: .background).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                self.task = recognizer.recognitionTask(with: request, resultHandler: self.recognitionHandler(result:error:))
            } catch {
                self.reset()
                self.speakError(error)
            }
        }
    }
    
    func stopTranscribing() {
        reset()
    }
    
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    
    private func recognitionHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
        }
        
        if let result = result {
            speak(result.bestTranscription.formattedString)
        }
    }
    
    private func speak(_ message: String) {
        transcript = message
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}


final class AIModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        let apiKey = Secrets.apiKey
        client = OpenAISwift(authToken: apiKey)
    }
    
    func send(text: String, complition: @escaping(String)->Void ){
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                complition(output)
            case .failure:
                break
            }
        })
    }
}


func scheduleReminder(forFName fname: String, forLName lname: String, inCity city: String, onDate dateString: String) {
    let eventStore = EKEventStore()
    let dateFormatter = DateFormatter()
    let year = Calendar.current.component(.year, from: Date())
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "MMMM dd 'at' h:mm a"
    
    // Request access to the reminders
    eventStore.requestAccess(to: .reminder) { granted, error in
        if granted {
            let reminder = EKReminder(eventStore: eventStore)
            
            // Set the reminder's title
            reminder.title = "Visit \(fname) \(lname) in \(city)"
            
            // Set the reminder's due date
            if let date = dateFormatter.date(from: dateString) {
                print(date)
                // Extract the date components from the parsed date
                var dateComponents = Calendar.current.dateComponents([.month, .day, .hour, .minute], from: date)
                
                // Add the current year to the date components
                dateComponents.year = year
                
                // Set the reminder's due date components
                reminder.dueDateComponents = dateComponents
            } else {
                // Invalid date format
                let content = UNMutableNotificationContent()
                content.title = "Invalid Date Format"
                content.body = "Please enter the date in the format 'Month DD at H:MM AM/PM'"
                let request = UNNotificationRequest(identifier: "InvalidDateFormat", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                return
            }
            
            // Add the reminder to the default reminders list
            let calendar = eventStore.defaultCalendarForNewReminders()
            reminder.calendar = calendar
            do {
                try eventStore.save(reminder, commit: true)
                // Reminder saved
                let content = UNMutableNotificationContent()
                content.title = "Reminder Saved"
                content.body = "Your reminder to visit \(fname) \(lname) in \(city) has been saved"
                let request = UNNotificationRequest(identifier: "ReminderSaved", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } catch {
                // Error saving reminder
                let content = UNMutableNotificationContent()
                content.title = "Error Saving Reminder"
                content.body = "An error occurred while saving your reminder: \(error.localizedDescription)"
                let request = UNNotificationRequest(identifier: "ErrorSavingReminder", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        } else {
            // Access to reminders denied
            let content = UNMutableNotificationContent()
            content.title = "Access to Reminders Denied"
            content.body = "Please grant access to reminders in your device settings to use this feature"
            let request = UNNotificationRequest(identifier: "AccessDenied", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}


func findContact(firstName: String, lastName: String, city: String) -> Contacts? {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "firstName == %@ AND lastName == %@ AND city == %@", firstName, lastName, city)
    
    do {
        let contacts = try context.fetch(fetchRequest)
        return contacts.first
    } catch let error {
        print("Error fetching contacts: \(error.localizedDescription)")
        return nil
    }
}

func checkReminder(firstName: String, lastName: String) -> Bool {
    let store = EKEventStore()
    let predicate = store.predicateForReminders(in: nil)
    var hasReminder = false
    store.fetchReminders(matching: predicate) { reminders in
        if let reminders = reminders {
            for reminder in reminders {
                if let title = reminder.title, title.contains(firstName) && title.contains(lastName) {
                    hasReminder = true
                    break
                }
            }
        }
    }
    return hasReminder
}

func deleteContact(contact : Contacts, viewContext : NSManagedObjectContext) {
    viewContext.delete(contact)
    do {
        try viewContext.save()
    } catch {
        print("Error saving context after delete: \(error)")
    }
}
