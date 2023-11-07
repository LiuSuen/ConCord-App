//
//  ExportContact.swift
//  EngEn
//
//  Created by Loaner on 3/31/23.
//

import SwiftUI
import ContactsUI

struct NewContactView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    var firstName: String
    var lastName: String
    var phoneNumber: String
    var emailAddress: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        contact.phoneNumbers.append(CNLabeledValue(label: "work", value: CNPhoneNumber(stringValue: phoneNumber)))
        contact.emailAddresses.append(CNLabeledValue(label: "work", value: emailAddress as NSString))

        let contactViewController = CNContactViewController(forNewContact: contact)
        contactViewController.delegate = context.coordinator

        let navigationController = UINavigationController(rootViewController: contactViewController)
        navigationController.navigationBar.tintColor = UIColor.systemBlue

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: NewContactView

        init(_ parent: NewContactView) {
            self.parent = parent
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            if contact != nil {
                let saveRequest = CNSaveRequest()
                // saveRequest.add(_ newContact, toContainerWithIdentifier: nil)
                do {
                    try CNContactStore().execute(saveRequest)
                } catch {
                    print("Error saving contact: \(error.localizedDescription)")
                }
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
